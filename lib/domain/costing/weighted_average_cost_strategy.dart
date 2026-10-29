import 'dart:math' as math;

import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../core/util/int_math.dart';
import 'cost_strategy.dart';

/// Costo promedio ponderado:
/// `nuevo = (stock * costoActual + totalCompra) / (stock + unidadesCompra)`.
///
/// Outflows are valued at the current average and do not change it.
class WeightedAverageCostStrategy implements CostStrategy {
  const WeightedAverageCostStrategy();

  @override
  StockState applyPurchase(
    StockState state, {
    required int units,
    required Money total,
  }) {
    if (units <= 0) throw InvalidQuantityException(units);
    if (total.isNegative) {
      throw const InvalidAmountException('El total de la compra no puede ser negativo');
    }
    // Negative stock (only if the policy allows it) carries no value.
    final held = math.max(state.units, 0);
    final rawValue = held * state.avgCost.raw + total.cents * UnitCost.rawPerCent;
    return StockState(
      units: state.units + units,
      avgCost: UnitCost(divRound(rawValue, held + units)),
    );
  }

  @override
  OutflowResult applyOutflow(
    StockState state, {
    required int units,
    required bool allowNegativeStock,
  }) {
    if (units <= 0) throw InvalidQuantityException(units);
    if (!allowNegativeStock && units > state.units) {
      throw InsufficientStockException(
        available: math.max(state.units, 0),
        requested: units,
      );
    }
    return OutflowResult(
      newState: StockState(units: state.units - units, avgCost: state.avgCost),
      unitCost: state.avgCost,
      totalCost: state.avgCost.totalFor(units),
    );
  }
}
