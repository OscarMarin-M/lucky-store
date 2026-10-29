import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/presentation/purchases/purchase_draft.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late Product snickers; // box of 24
  late Product gum; // no boxes

  PurchaseDraft draft() => container.read(purchaseDraftProvider.notifier);
  PurchaseDraftState state() => container.read(purchaseDraftProvider);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    final products = container.read(productRepositoryProvider);
    snickers = await products.create(Product.create(name: 'Snickers', unitsPerBox: 24));
    gum = await products.create(Product.create(name: 'Gum'));
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('lines start in boxes only when the product has boxes', () {
    draft()
      ..addProduct(snickers)
      ..addProduct(gum);
    expect(state().lines[0].presentation, Presentation.box);
    expect(state().lines[1].presentation, Presentation.unit);
    expect(state().lines.every((l) => l.quantity == 1), isTrue);
  });

  test('cannot submit until every line has a valid quantity and price', () {
    expect(state().canSubmit, isFalse, reason: 'empty draft');

    draft().addProduct(snickers);
    final id = state().lines.single.id;
    expect(state().canSubmit, isFalse, reason: 'no price yet');

    draft().setPrice(id, '1.234');
    expect(state().canSubmit, isFalse, reason: 'more than 2 decimals');

    draft().setPrice(id, '48,50');
    expect(state().canSubmit, isTrue);

    draft().setQuantity(id, 0);
    expect(state().canSubmit, isFalse, reason: 'quantity 0');
  });

  test('line shows base units and the total adds up', () {
    draft()
      ..addProduct(snickers)
      ..addProduct(gum);
    final a = state().lines[0].id;
    final b = state().lines[1].id;
    draft()
      ..setQuantity(a, 2)
      ..setPrice(a, '48')
      ..setQuantity(b, 10)
      ..setPrice(b, '1,25');

    expect(state().lines[0].unitsBase, 48);
    expect(state().lines[1].unitsBase, 10);
    expect(state().total, const Money(10850));
  });

  test('the price is per box: total = price x boxes, and the unit cost', () {
    draft().addProduct(snickers); // 24 u per box
    final id = state().lines.single.id;
    draft()
      ..setQuantity(id, 3)
      ..setPrice(id, '50');

    final line = state().lines.single;
    expect(line.lineTotal, const Money(15000));
    expect(line.unitsBase, 72);
    expect(line.unitCost!.raw, 20833); // 50 / 24 = 2,0833 per unit
  });

  test('switching box/unit clears the typed price', () {
    draft().addProduct(snickers);
    final id = state().lines.single.id;
    draft()
      ..setPrice(id, '50')
      ..setPresentation(id, Presentation.unit);
    expect(state().lines.single.priceText, isEmpty);
    expect(state().canSubmit, isFalse);
  });

  test('removeLine and clear', () {
    draft()
      ..addProduct(snickers)
      ..addProduct(gum);
    draft().removeLine(state().lines.first.id);
    expect(state().lines.single.product.name, 'Gum');
    draft().clear();
    expect(state().lines, isEmpty);
  });

  test('submit registers the purchase, updates stock and empties the draft',
      () async {
    draft()
      ..addProduct(snickers)
      ..setSupplier('  Distribuidora Sur ')
      ..setDate(DateTime(2026, 10, 1));
    final id = state().lines.single.id;
    draft()
      ..setQuantity(id, 2)
      ..setPrice(id, '48');

    final purchase = await draft().submit();

    expect(purchase.total, const Money(9600));
    expect(purchase.supplier, 'Distribuidora Sur');
    expect(purchase.date, DateTime(2026, 10, 1));
    final stored = (await container.read(productRepositoryProvider).getById(snickers.id))!;
    expect(stored.stockUnits, 48);
    expect(stored.avgCost.raw, 20000);
    expect(state().lines, isEmpty);
    expect(state().supplier, isEmpty);
  });

  test('a rejected submit keeps the draft', () async {
    draft().addProduct(snickers);
    final id = state().lines.single.id;
    draft().setPrice(id, '10');
    await container.read(productRepositoryProvider).softDelete(snickers.id);

    await expectLater(draft().submit(), throwsA(isA<EntityNotFoundException>()));
    expect(state().lines, hasLength(1));
  });
}
