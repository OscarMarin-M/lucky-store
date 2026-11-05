import '../../domain/costing/cost_strategy.dart';
import '../../domain/purchasing/purchase_lot.dart';

/// The arithmetic behind a lot's figures, written out with the real numbers
/// so the owner can check them by hand:
///
/// 1. what one unit of the lot costs (a box price divided by its units), and
/// 2. how the lot moves the product's weighted average cost.
///
/// [before] is the product's stock before this lot and [after] what the cost
/// strategy computed with it; the last figure always comes from [after], so
/// the text can never disagree with what is stored.
List<String> costFormulaLines(
  PurchaseLot lot, {
  required StockState before,
  required StockState after,
}) {
  final units = lot.unitsBase;
  final lines = <String>[
    switch (lot) {
      BoxLot(:final boxes, :final pricePerBox) when boxes > 1 =>
        'Total: $boxes cajas × ${pricePerBox.format()} = '
            '${lot.lineTotal.format()}',
      BoxLot() => 'Total: 1 caja = ${lot.lineTotal.format()}',
      LooseUnitsLot(:final unitPrice) =>
        'Total: $units u × ${unitPrice.format()} = ${lot.lineTotal.format()}',
    },
    // Loose units are typed at their unit price: nothing to divide.
    if (lot is BoxLot)
      'Costo c/u: ${lot.lineTotal.format()} ÷ $units u = '
          '${lot.unitCost.format()}',
  ];

  // Units already held are what get averaged with the lot. Negative stock
  // (sold offline before buying) carries no value, like in the strategy.
  final held = before.units;
  if (held <= 0) {
    lines.add(
      held == 0
          ? 'Sin stock antes: el costo promedio queda en el de este lote, '
              '${after.avgCost.format()}'
          : 'Stock negativo ($held u): no tiene valor, el costo promedio '
              'queda en el de este lote, ${after.avgCost.format()}',
    );
    return lines;
  }
  final heldValue = before.avgCost.totalFor(held);
  lines.addAll([
    'Costo promedio = (stock × costo actual + total) ÷ (stock + unidades)',
    '= ($held u × ${before.avgCost.format()} + ${lot.lineTotal.format()}) '
        '÷ ($held + $units) u',
    '= ${(heldValue + lot.lineTotal).format()} ÷ ${held + units} u = '
        '${after.avgCost.format()} c/u',
  ]);
  return lines;
}
