import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';

/// Inventory position of one product, always in base units.
final class StockState {
  const StockState({required this.units, required this.avgCost});

  static const empty = StockState(units: 0, avgCost: UnitCost.zero);

  final int units;
  final UnitCost avgCost;

  @override
  bool operator ==(Object other) =>
      other is StockState && other.units == units && other.avgCost == avgCost;

  @override
  int get hashCode => Object.hash(units, avgCost);

  @override
  String toString() => 'StockState(units: $units, avgCost: $avgCost)';
}

/// Result of taking units out of stock (sale, shrinkage, gift, expiry).
final class OutflowResult {
  const OutflowResult({
    required this.newState,
    required this.unitCost,
    required this.totalCost,
  });

  final StockState newState;

  /// Cost of one unit at the moment of the outflow (frozen in the history).
  final UnitCost unitCost;

  /// Cost of all units taken out, rounded to centavos.
  final Money totalCost;
}

/// Costing method. Today: weighted average. To move to FIFO, add another
/// implementation (it will need cost layers persisted) and swap it where the
/// use cases are built; sales/purchases/UI do not change.
abstract interface class CostStrategy {
  /// Stock after receiving [units] base units that cost [total] in all.
  StockState applyPurchase(
    StockState state, {
    required int units,
    required Money total,
  });

  /// Stock after taking [units] base units out, and what they cost.
  ///
  /// Throws `InsufficientStockException` when it would go below zero and
  /// [allowNegativeStock] is false.
  OutflowResult applyOutflow(
    StockState state, {
    required int units,
    required bool allowNegativeStock,
  });
}
