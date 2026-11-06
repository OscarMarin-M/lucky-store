import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
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

  group('bags (v10)', () {
    final bagged = Product.create(
      name: 'Skittles',
      suggestedPriceUnit: const Money(100),
      unitsPerBag: 30,
    );

    test('offers only the packs the product defines', () {
      expect(base.presentations, [Presentation.unit, Presentation.box]);
      expect(bagged.presentations, [Presentation.unit, Presentation.bag]);
      expect(
        base.copyWith(unitsPerBag: 50).presentations,
        [Presentation.unit, Presentation.box, Presentation.bag],
      );
    });

    test('converts with its own bag size', () {
      expect(bagged.toBase(2, Presentation.bag), 60);
      expect(bagged.unitsIn(Presentation.bag), 30);
      expect(base.unitsIn(Presentation.bag), isNull);
      expect(
        () => base.toBase(1, Presentation.bag),
        throwsA(isA<MissingBagSizeException>()),
      );
    });

    test('bag price: its own, else units x unit price', () {
      expect(bagged.suggestedPriceFor(Presentation.bag), const Money(3000));
      expect(
        bagged
            .copyWith(suggestedPriceBag: const Money(2500))
            .suggestedPriceFor(Presentation.bag),
        const Money(2500),
      );
    });

    test('withDetails can clear the bag; rejects a size < 1', () {
      final cleared = bagged.withDetails(
        name: 'Skittles',
        unitsPerBox: 1,
        suggestedPriceUnit: const Money(100),
        unitsPerBag: null,
        isActive: true,
      );
      expect(cleared.hasBags, isFalse);
      expect(
        () => Product.create(name: 'x', unitsPerBag: 0),
        throwsA(isA<InvalidUnitsPerBagException>()),
      );
    });
  });
}
