import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/domain/purchasing/purchase_lot.dart';

void main() {
  group('BoxLot', () {
    test('units and total come from the box size of THIS lot', () {
      final lot = BoxLot(boxes: 2, unitsPerBox: 36, pricePerBox: Money.parse('72'));
      expect(lot.unitsBase, 72);
      expect(lot.lineTotal, const Money(14400));
      expect(lot.unitCost.raw, 20000); // 72 / 36 = Bs 2,00 c/u
      expect(lot.presentation, Presentation.box);
      expect(lot.quantity, 2);
      expect(lot.unitsPerBox, 36);
    });

    test('keeps 4 decimals when the box does not divide evenly', () {
      final lot = BoxLot(boxes: 1, unitsPerBox: 24, pricePerBox: Money.parse('50'));
      expect(lot.unitCost.raw, 20833); // 2,0833
    });

    test('one expiry date (day only) and a trimmed code', () {
      final lot = BoxLot(
        boxes: 1,
        unitsPerBox: 24,
        pricePerBox: Money.parse('48'),
        expiry: DateTime(2027, 3, 15, 18, 30),
        lotCode: '  L-2291 ',
      );
      expect(lot.expiryFrom, DateTime(2027, 3, 15));
      expect(lot.expiryTo, DateTime(2027, 3, 15));
      expect(lot.lotCode, 'L-2291');
      expect(
        BoxLot(boxes: 1, unitsPerBox: 24, pricePerBox: Money.zero, lotCode: ' ')
            .lotCode,
        isNull,
      );
    });

    test('rejects 0 boxes, box size 0 and negative prices', () {
      expect(() => BoxLot(boxes: 0, unitsPerBox: 24, pricePerBox: Money.zero),
          throwsA(isA<InvalidQuantityException>()));
      expect(() => BoxLot(boxes: 1, unitsPerBox: 0, pricePerBox: Money.zero),
          throwsA(isA<InvalidUnitsPerBoxException>()));
      expect(
          () => BoxLot(boxes: 1, unitsPerBox: 24, pricePerBox: const Money(-1)),
          throwsA(isA<InvalidAmountException>()));
    });
  });

  group('LooseUnitsLot', () {
    test('price per unit x units', () {
      final lot = LooseUnitsLot(units: 10, unitPrice: Money.parse('1,80'));
      expect(lot.unitsBase, 10);
      expect(lot.lineTotal, const Money(1800));
      expect(lot.unitCost.raw, 18000);
      expect(lot.presentation, Presentation.unit);
      expect(lot.unitsPerBox, isNull);
      expect(lot.lotCode, isNull);
    });

    test('by amount: Bs 20 at Bs 0,50 each = 40 units', () {
      final lot = LooseUnitsLot.byAmount(
        amount: Money.parse('20'),
        unitPrice: Money.parse('0,50'),
      );
      expect(lot.units, 40);
      expect(lot.lineTotal, Money.parse('20'));
    });

    test('by amount rejects amounts that do not buy whole units', () {
      expect(
        () => LooseUnitsLot.byAmount(
            amount: Money.parse('10'), unitPrice: Money.parse('3')),
        throwsA(isA<InvalidAmountException>()),
      );
      expect(
        () => LooseUnitsLot.byAmount(
            amount: Money.parse('10'), unitPrice: Money.zero),
        throwsA(isA<InvalidAmountException>()),
      );
    });

    test('expiry range; a single date fills both ends', () {
      final range = LooseUnitsLot(
        units: 10,
        unitPrice: const Money(100),
        expiryFrom: DateTime(2027, 1, 10),
        expiryTo: DateTime(2027, 2, 20),
      );
      expect(range.expiryFrom, DateTime(2027, 1, 10));
      expect(range.expiryTo, DateTime(2027, 2, 20));

      final onlyTo = LooseUnitsLot(
          units: 1, unitPrice: Money.zero, expiryTo: DateTime(2027, 5, 1));
      expect(onlyTo.expiryFrom, DateTime(2027, 5, 1));
      expect(onlyTo.expiryTo, DateTime(2027, 5, 1));
    });

    test('rejects a range that ends before it starts, and 0 units', () {
      expect(
        () => LooseUnitsLot(
          units: 1,
          unitPrice: Money.zero,
          expiryFrom: DateTime(2027, 2, 1),
          expiryTo: DateTime(2027, 1, 1),
        ),
        throwsA(isA<InvalidExpiryRangeException>()),
      );
      expect(() => LooseUnitsLot(units: 0, unitPrice: Money.zero),
          throwsA(isA<InvalidQuantityException>()));
    });
  });
}
