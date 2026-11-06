import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/quantity/presentation.dart';

void main() {
  group('toBaseUnits', () {
    test('units stay as they are', () {
      expect(
        toBaseUnits(quantity: 7, presentation: Presentation.unit, unitsPerBox: 24),
        7,
      );
    });

    test('boxes multiply by unitsPerBox', () {
      expect(
        toBaseUnits(quantity: 3, presentation: Presentation.box, unitsPerBox: 24),
        72,
      );
    });

    test('product without boxes (unitsPerBox 1)', () {
      expect(
        toBaseUnits(quantity: 5, presentation: Presentation.box, unitsPerBox: 1),
        5,
      );
    });

    test('rejects non-positive quantity', () {
      for (final q in [0, -1]) {
        expect(
          () => toBaseUnits(quantity: q, presentation: Presentation.unit, unitsPerBox: 12),
          throwsA(isA<InvalidQuantityException>()),
        );
      }
    });

    test('rejects unitsPerBox < 1', () {
      expect(
        () => toBaseUnits(quantity: 1, presentation: Presentation.box, unitsPerBox: 0),
        throwsA(isA<InvalidUnitsPerBoxException>()),
      );
    });
  });

  group('bags (v10)', () {
    test('bags multiply by unitsPerBag, independent of the box', () {
      expect(
        toBaseUnits(
          quantity: 2,
          presentation: Presentation.bag,
          unitsPerBox: 24,
          unitsPerBag: 30,
        ),
        60,
      );
    });

    test('a product without bag size cannot convert bags', () {
      expect(
        () => toBaseUnits(quantity: 1, presentation: Presentation.bag, unitsPerBox: 24),
        throwsA(isA<MissingBagSizeException>()),
      );
      expect(
        () => toBaseUnits(
          quantity: 1,
          presentation: Presentation.bag,
          unitsPerBox: 1,
          unitsPerBag: 0,
        ),
        throwsA(isA<InvalidUnitsPerBagException>()),
      );
    });

    test('names in Spanish, singular and plural', () {
      expect(Presentation.bag.nameFor(1), 'bolsa');
      expect(Presentation.bag.nameFor(3), 'bolsas');
      expect(Presentation.box.nameFor(2), 'cajas');
      expect(Presentation.bag.eachSuffix, 'c/bolsa');
      expect(Presentation.unit.isPack, isFalse);
      expect(Presentation.bag.isPack, isTrue);
    });
  });
}
