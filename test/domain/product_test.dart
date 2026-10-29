import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/domain/entities/product.dart';

void main() {
  final base = Product.create(
    name: 'Snickers',
    sku: 'SNK',
    unitsPerBox: 24,
    suggestedPriceUnit: const Money(300),
    suggestedPriceBox: const Money(6500),
  ).copyWith(stockUnits: 30, avgCost: const UnitCost(20000));

  test('withDetails can clear sku and box price but keeps stock and cost', () {
    final edited = base.withDetails(
      name: 'Snickers 50g',
      sku: null,
      unitsPerBox: 24,
      suggestedPriceUnit: const Money(350),
      suggestedPriceBox: null,
      isActive: false,
    );
    expect(edited.id, base.id);
    expect(edited.name, 'Snickers 50g');
    expect(edited.sku, isNull);
    expect(edited.suggestedPriceBox, isNull);
    expect(edited.isActive, isFalse);
    expect(edited.stockUnits, 30);
    expect(edited.avgCost, const UnitCost(20000));
  });

  test('withDetails rejects unitsPerBox < 1', () {
    expect(
      () => base.withDetails(
        name: 'x',
        unitsPerBox: 0,
        suggestedPriceUnit: Money.zero,
        isActive: true,
      ),
      throwsA(isA<InvalidUnitsPerBoxException>()),
    );
  });

  test('stockValue is stock x average cost', () {
    expect(base.stockValue, const Money(6000)); // 30 x 2,00
  });
}
