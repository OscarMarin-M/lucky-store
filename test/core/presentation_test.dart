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
}
