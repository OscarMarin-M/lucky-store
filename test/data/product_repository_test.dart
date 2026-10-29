import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/domain/entities/product.dart';

import 'test_env.dart';

void main() {
  late TestEnv env;

  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  Product candy(String name, {String? sku}) => Product.create(
        name: name,
        sku: sku,
        unitsPerBox: 24,
        suggestedPriceUnit: const Money(300),
        suggestedPriceBox: const Money(6500),
      );

  test('create and getById round-trip every field', () async {
    final p = await env.products.create(candy('Snickers', sku: 'SNK-1'));
    final read = (await env.products.getById(p.id))!;
    expect(read.name, 'Snickers');
    expect(read.sku, 'SNK-1');
    expect(read.unitsPerBox, 24);
    expect(read.suggestedPriceUnit, const Money(300));
    expect(read.suggestedPriceBox, const Money(6500));
    expect(read.stockUnits, 0);
    expect(read.avgCost, UnitCost.zero);
    expect(read.isActive, isTrue);
    expect(read.deletedAt, isNull);
  });

  test('update changes fields and bumps updatedAt', () async {
    final p = await env.products.create(candy('Snickers'));
    await Future<void>.delayed(const Duration(seconds: 1));
    await env.products.update(p.copyWith(name: 'Snickers 50g', unitsPerBox: 36));
    final read = (await env.products.getById(p.id))!;
    expect(read.name, 'Snickers 50g');
    expect(read.unitsPerBox, 36);
    expect(read.createdAt.isAtSameMomentAs(p.createdAt), isTrue);
    expect(read.updatedAt.isAfter(p.updatedAt), isTrue);
  });

  test('update of a missing product throws', () async {
    expect(() => env.products.update(candy('Fantasma')),
        throwsA(isA<EntityNotFoundException>()));
  });

  test('softDelete hides the row, restore brings it back', () async {
    final p = await env.products.create(candy('Twix'));
    await env.products.softDelete(p.id);

    expect(await env.products.getById(p.id), isNull);
    expect(await env.products.getAll(), isEmpty);
    final hidden = await env.products.getById(p.id, includeDeleted: true);
    expect(hidden!.isDeleted, isTrue);

    await env.products.restore(p.id);
    expect((await env.products.getById(p.id))!.isDeleted, isFalse);
  });

  test('getAll is ordered by name and search matches name or sku', () async {
    await env.products.create(candy('Twix', sku: 'TW'));
    await env.products.create(candy('M&Ms', sku: 'MM-RED'));
    await env.products.create(candy('Snickers', sku: 'SNK'));

    expect((await env.products.getAll()).map((p) => p.name),
        ['M&Ms', 'Snickers', 'Twix']);
    expect((await env.products.search('tw')).map((p) => p.name), ['Twix']);
    expect((await env.products.search('mm-')).map((p) => p.name), ['M&Ms']);
  });

  test('watchAll emits when products change', () async {
    final stream = env.products.watchAll();
    final emissions = <List<String>>[];
    final sub = stream.listen((l) => emissions.add(l.map((p) => p.name).toList()));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await env.products.create(candy('Hershey'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(emissions.first, isEmpty);
    expect(emissions.last, ['Hershey']);
  });

  test('suggestedPriceFor falls back to unit price x unitsPerBox', () {
    final p = Product.create(
      name: 'Gum',
      unitsPerBox: 10,
      suggestedPriceUnit: const Money(150),
    );
    expect(p.suggestedPriceFor(Presentation.box), const Money(1500));
  });

  test('Product.create rejects unitsPerBox < 1', () {
    expect(() => Product.create(name: 'X', unitsPerBox: 0),
        throwsA(isA<InvalidUnitsPerBoxException>()));
  });
}
