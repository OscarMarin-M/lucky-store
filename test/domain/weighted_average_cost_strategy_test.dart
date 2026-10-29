import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/domain/costing/cost_strategy.dart';
import 'package:lucky_store/domain/costing/weighted_average_cost_strategy.dart';

void main() {
  const strategy = WeightedAverageCostStrategy();

  StockState state(int units, int costRaw) =>
      StockState(units: units, avgCost: UnitCost(costRaw));

  group('applyPurchase', () {
    test('first purchase sets the cost to total / units', () {
      final s = strategy.applyPurchase(StockState.empty,
          units: 24, total: const Money(4800));
      expect(s.units, 24);
      expect(s.avgCost.raw, 20000); // Bs 2,00
    });

    test('second purchase at a different cost is weighted', () {
      // 10 units @ Bs 2,00 + 30 units @ Bs 3,00 total Bs 90 => Bs 2,75
      final s = strategy.applyPurchase(state(10, 20000),
          units: 30, total: const Money(9000));
      expect(s.units, 40);
      expect(s.avgCost.raw, 27500);
    });

    test('purchase on empty stock ignores the old cost', () {
      final s = strategy.applyPurchase(state(0, 99999),
          units: 10, total: const Money(1000));
      expect(s.avgCost.raw, 10000);
    });

    test('negative stock carries no value into the average', () {
      final s = strategy.applyPurchase(state(-5, 50000),
          units: 10, total: const Money(1000));
      expect(s.units, 5);
      expect(s.avgCost.raw, 10000);
    });

    test('rounds the average to 4 decimals', () {
      // 1 unit @ 1,00 + 2 units for 1,00 => 2,00 / 3 = 0,6667
      final s = strategy.applyPurchase(state(1, 10000),
          units: 2, total: const Money(100));
      expect(s.avgCost.raw, 6667);
    });

    test('a free purchase (gift stock) lowers the average', () {
      final s = strategy.applyPurchase(state(10, 20000),
          units: 10, total: Money.zero);
      expect(s.avgCost.raw, 10000);
    });

    test('rejects invalid input', () {
      expect(() => strategy.applyPurchase(StockState.empty, units: 0, total: const Money(1)),
          throwsA(isA<InvalidQuantityException>()));
      expect(() => strategy.applyPurchase(StockState.empty, units: 1, total: const Money(-1)),
          throwsA(isA<InvalidAmountException>()));
    });
  });

  group('applyOutflow', () {
    test('values units at the current average and keeps it', () {
      final r = strategy.applyOutflow(state(40, 27500),
          units: 4, allowNegativeStock: false);
      expect(r.unitCost.raw, 27500);
      expect(r.totalCost, const Money(1100)); // 4 x 2,75
      expect(r.newState.units, 36);
      expect(r.newState.avgCost.raw, 27500);
    });

    test('emptying the stock keeps the last cost', () {
      final r = strategy.applyOutflow(state(5, 12345),
          units: 5, allowNegativeStock: false);
      expect(r.newState.units, 0);
      expect(r.newState.avgCost.raw, 12345);
    });

    test('blocks selling more than the stock by default', () {
      expect(
        () => strategy.applyOutflow(state(3, 10000),
            units: 4, allowNegativeStock: false),
        throwsA(isA<InsufficientStockException>()
            .having((e) => e.available, 'available', 3)
            .having((e) => e.requested, 'requested', 4)),
      );
    });

    test('allows negative stock when the policy says so', () {
      final r = strategy.applyOutflow(state(3, 10000),
          units: 5, allowNegativeStock: true);
      expect(r.newState.units, -2);
    });

    test('rejects non-positive units', () {
      expect(
        () => strategy.applyOutflow(state(3, 10000),
            units: 0, allowNegativeStock: false),
        throwsA(isA<InvalidQuantityException>()),
      );
    });
  });
}
