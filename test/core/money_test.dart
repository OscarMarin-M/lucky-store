import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/core/util/int_math.dart';

void main() {
  group('divRound', () {
    test('rounds half away from zero', () {
      expect(divRound(5, 2), 3);
      expect(divRound(-5, 2), -3);
      expect(divRound(4, 3), 1);
      expect(divRound(5, 3), 2);
      expect(divRound(0, 7), 0);
    });
  });

  group('Money', () {
    test('parse accepts dot or comma and pads decimals', () {
      expect(Money.parse('12'), const Money(1200));
      expect(Money.parse('12.5'), const Money(1250));
      expect(Money.parse('12,50'), const Money(1250));
      expect(Money.parse(' 0,05 '), const Money(5));
      expect(Money.parse('-3.10'), const Money(-310));
    });

    test('parse rejects invalid input and more than 2 decimals', () {
      expect(() => Money.parse('abc'), throwsA(isA<InvalidAmountException>()));
      expect(() => Money.parse('1.234'), throwsA(isA<InvalidAmountException>()));
      expect(() => Money.parse(''), throwsA(isA<InvalidAmountException>()));
    });

    test('arithmetic is exact (no float drift)', () {
      expect(Money.parse('0.10') + Money.parse('0.20'), Money.parse('0.30'));
      expect(const Money(1250).times(3), const Money(3750));
      expect(const Money(500) - const Money(750), const Money(-250));
    });

    test('format', () {
      expect(const Money(1250).format(), 'Bs 12,50');
      expect(const Money(5).format(), 'Bs 0,05');
      expect(const Money(-1250).format(symbol: false), '-12,50');
    });

    test('sum of an iterable', () {
      expect([const Money(100), const Money(250)].sum, const Money(350));
      expect(<Money>[].sum, Money.zero);
    });
  });

  group('UnitCost', () {
    test('keeps 4 decimals when splitting a box', () {
      // Bs 50,00 for 24 units = 2,0833 per unit (not 2,08).
      final cost = UnitCost.fromTotal(const Money(5000), 24);
      expect(cost.raw, 20833);
      expect(cost.format(), 'Bs 2,0833');
    });

    test('total rounds half-up to centavos', () {
      final cost = UnitCost.fromTotal(const Money(5000), 24);
      // 24 units -> 4999.92 centavos-ish -> 5000
      expect(cost.totalFor(24), const Money(5000));
      // 1 unit -> 2,0833 -> 2,08
      expect(cost.totalFor(1), const Money(208));
    });

    test('exact costs round-trip', () {
      final cost = UnitCost.fromTotal(const Money(1200), 12);
      expect(cost.raw, 10000);
      expect(cost.totalFor(12), const Money(1200));
    });
  });
}
