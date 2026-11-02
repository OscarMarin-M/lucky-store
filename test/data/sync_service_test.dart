import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/data/sync/inventory_rebuilder.dart';
import 'package:lucky_store/data/sync/remote_store.dart';
import 'package:lucky_store/data/sync/sync_service.dart';
import 'package:lucky_store/domain/costing/weighted_average_cost_strategy.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/domain/entities/stock_adjustment.dart';
import 'package:lucky_store/domain/purchasing/purchase_lot.dart';
import 'package:lucky_store/domain/usecases/register_purchase.dart';
import 'package:lucky_store/domain/usecases/register_sale.dart';

import 'test_env.dart';

/// The cloud in memory: upserts by id and stamps `server_updated_at` with
/// its own clock, like the trigger in supabase/migrations does.
class FakeRemoteStore implements RemoteStore {
  final tables = <String, Map<String, Map<String, Object?>>>{};
  final _stamps = <String, DateTime>{};
  var _clock = DateTime.utc(2026, 11, 1);

  @override
  Future<void> upsert(String table, List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      _clock = _clock.add(const Duration(microseconds: 1));
      final id = row['id']! as String;
      _stamps['$table/$id'] = _clock;
      // PostgREST answers timestamps with an explicit +00:00 offset.
      tables.putIfAbsent(table, () => {})[id] = {
        ...row,
        'server_updated_at': _clock.toIso8601String().replaceFirst(
          'Z',
          '+00:00',
        ),
      };
    }
  }

  @override
  Future<List<Map<String, Object?>>> changesSince(
    String table, {
    SyncCursor? after,
    required int limit,
  }) async {
    DateTime stamp(Map<String, Object?> r) => _stamps['$table/${r['id']}']!;
    final rows = (tables[table]?.values.toList() ?? [])
      ..sort((a, b) {
        final byStamp = stamp(a).compareTo(stamp(b));
        return byStamp != 0
            ? byStamp
            : (a['id']! as String).compareTo(b['id']! as String);
      });
    final from = after == null ? null : DateTime.parse(after.serverUpdatedAt);
    return rows
        .where(
          (r) =>
              from == null ||
              stamp(r).isAfter(from) ||
              (stamp(r) == from && (r['id']! as String).compareTo(after!.id) > 0),
        )
        .take(limit)
        .map((r) => Map.of(r))
        .toList();
  }
}

/// One phone: its own database, use cases and sync.
class Phone {
  Phone(RemoteStore remote, {int pageSize = 500}) : env = TestEnv() {
    sync = SyncService(
      env.db,
      remote,
      InventoryRebuilder(env.db, const WeightedAverageCostStrategy()),
      pageSize: pageSize,
    );
  }

  final TestEnv env;
  late final SyncService sync;

  Future<Product> product(String id) async => (await env.products.getById(id))!;

  Future<int> pending() => sync.watchPending().first;

  Future<void> buyUnits(String productId, int units, int unitPriceCents) =>
      env.registerPurchase(
        lines: [
          PurchaseLineInput(
            productId: productId,
            lot: LooseUnitsLot(units: units, unitPrice: Money(unitPriceCents)),
          ),
        ],
      );

  Future<void> sell(String productId, int units) => env.registerSale(
    lines: [
      SaleLineInput(
        productId: productId,
        quantity: units,
        presentation: Presentation.unit,
      ),
    ],
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FakeRemoteStore cloud;
  late Phone a;
  late Phone b;

  setUp(() {
    cloud = FakeRemoteStore();
    a = Phone(cloud);
    b = Phone(cloud);
  });
  tearDown(() async {
    await a.env.dispose();
    await b.env.dispose();
  });

  Future<Product> newCandy(Phone phone) => phone.env.products.create(
    Product.create(name: 'Snickers', suggestedPriceUnit: const Money(500)),
  );

  test('what one phone registers reaches the other with the same stock', () async {
    final p = await newCandy(a);
    await a.buyUnits(p.id, 10, 200);
    await a.buyUnits(p.id, 10, 300);
    await a.sell(p.id, 4);
    await a.env.registerAdjustment(
      productId: p.id,
      quantity: 1,
      presentation: Presentation.unit,
      reason: AdjustmentReason.expired,
    );

    final pushed = await a.sync.sync();
    expect(pushed.pushed, greaterThan(0));
    expect(await a.pending(), 0);
    await b.sync.sync();

    final there = await b.product(p.id);
    expect(there.name, 'Snickers');
    expect(there.stockUnits, 15);
    expect(there.avgCost, (await a.product(p.id)).avgCost); // Bs 2,50
    expect((await b.env.sales.getAll()).single.total, const Money(2000));
    expect((await b.env.purchases.getAll()), hasLength(2));
    expect((await b.env.adjustments.getAll()), hasLength(1));
    expect(await b.pending(), 0, reason: 'downloaded rows are not sent back');
  });

  test('two phones selling offline at once end with the same stock', () async {
    final p = await newCandy(a);
    await a.buyUnits(p.id, 10, 200);
    await a.sync.sync();
    await b.sync.sync();

    // Both offline: each sells from the 10 it sees.
    await a.sell(p.id, 3);
    await b.sell(p.id, 4);

    await a.sync.sync();
    await b.sync.sync();
    await a.sync.sync();

    expect((await a.product(p.id)).stockUnits, 3);
    expect((await b.product(p.id)).stockUnits, 3);
    expect(await a.env.sales.getAll(), hasLength(2));
    expect(await b.env.sales.getAll(), hasLength(2));
  });

  test('selling the last unit twice offline shows negative stock', () async {
    final p = await newCandy(a);
    await a.buyUnits(p.id, 1, 200);
    await a.sync.sync();
    await b.sync.sync();

    await a.sell(p.id, 1);
    await b.sell(p.id, 1);
    await a.sync.sync();
    await b.sync.sync();
    await a.sync.sync();

    expect((await a.product(p.id)).stockUnits, -1);
    expect((await b.product(p.id)).stockUnits, -1);
  });

  test('a sale does not queue the product; editing the catalog does', () async {
    final p = await newCandy(a);
    await a.buyUnits(p.id, 5, 200);
    await a.sync.sync();

    await a.sell(p.id, 1);
    expect(
      (await a.env.db.select(a.env.db.syncOutbox).get()).map((e) => e.tableName$),
      isNot(contains('products')),
    );

    final current = await a.product(p.id);
    await a.env.products.update(
      current.withDetails(
        name: 'Snickers 50 g',
        unitsPerBox: 1,
        suggestedPriceUnit: const Money(600),
        isActive: true,
      ),
    );
    await a.sync.sync();
    await b.sync.sync();
    final there = await b.product(p.id);
    expect(there.name, 'Snickers 50 g');
    expect(there.suggestedPriceUnit, const Money(600));
    expect(there.stockUnits, 4);
  });

  test('saving a product loaded before a sale keeps the new stock', () async {
    final p = await newCandy(a);
    await a.buyUnits(p.id, 5, 200);
    final stale = await a.product(p.id); // e.g. the form was open
    await a.sell(p.id, 2);

    await a.env.products.update(
      stale.withDetails(
        name: 'Snickers',
        unitsPerBox: 1,
        suggestedPriceUnit: const Money(550),
        isActive: true,
      ),
    );
    expect((await a.product(p.id)).stockUnits, 3);
  });

  test('a local change not uploaded yet wins over the downloaded one', () async {
    final p = await newCandy(a);
    await a.sync.sync();
    await b.sync.sync();

    final onB = await b.product(p.id);
    await b.env.products.update(
      onB.withDetails(
        name: 'Nombre de B',
        unitsPerBox: 1,
        suggestedPriceUnit: const Money(500),
        isActive: true,
      ),
    );
    final onA = await a.product(p.id);
    await a.env.products.update(
      onA.withDetails(
        name: 'Nombre de A',
        unitsPerBox: 1,
        suggestedPriceUnit: const Money(500),
        isActive: true,
      ),
    );
    await a.sync.sync();

    // B downloads A's name only after pushing its own: last upload wins.
    await b.sync.pull();
    expect((await b.product(p.id)).name, 'Nombre de B');
    await b.sync.sync();
    await a.sync.sync();
    expect((await a.product(p.id)).name, 'Nombre de B');
    expect((await b.product(p.id)).name, 'Nombre de B');
  });

  test('downloads in pages and does not repeat rows between rounds', () async {
    final small = Phone(cloud, pageSize: 2);
    addTearDown(small.env.dispose);
    for (var i = 0; i < 5; i++) {
      final p = await a.env.products.create(Product.create(name: 'P$i'));
      await a.buyUnits(p.id, 1, 100);
    }
    await a.sync.sync();

    final first = await small.sync.pull();
    expect(first, 15); // 5 products + 5 purchases + 5 lines
    expect(await small.env.products.getAll(), hasLength(5));
    expect(await small.sync.pull(), 0);
  });
}
