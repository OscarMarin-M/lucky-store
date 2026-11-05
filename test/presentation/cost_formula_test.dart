import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/domain/costing/cost_strategy.dart';
import 'package:lucky_store/domain/costing/weighted_average_cost_strategy.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/domain/purchasing/purchase_lot.dart';
import 'package:lucky_store/presentation/format/cost_formula.dart';

void main() {
  const strategy = WeightedAverageCostStrategy();

  List<String> linesFor(PurchaseLot lot, StockState before) => costFormulaLines(
        lot,
        before: before,
        after: strategy.applyPurchase(
          before,
          units: lot.unitsBase,
          total: lot.lineTotal,
        ),
      );

  test('a box of 36 averaged with 24 units in stock', () {
    final lot = BoxLot(boxes: 1, unitsPerBox: 36, pricePerBox: const Money(7200));
    final lines = linesFor(
      lot,
      const StockState(units: 24, avgCost: UnitCost(21000)),
    );
    expect(lines, [
      'Total: 1 caja = Bs 72,00',
      'Costo c/u: Bs 72,00 ÷ 36 u = Bs 2,0000',
      'Costo promedio = (stock × costo actual + total) ÷ (stock + unidades)',
      '= (24 u × Bs 2,1000 + Bs 72,00) ÷ (24 + 36) u',
      '= Bs 122,40 ÷ 60 u = Bs 2,0400 c/u',
    ]);
  });

  test('a box price that does not divide evenly keeps 4 decimals', () {
    final lot = BoxLot(boxes: 2, unitsPerBox: 24, pricePerBox: const Money(5000));
    expect(linesFor(lot, StockState.empty), [
      'Total: 2 cajas × Bs 50,00 = Bs 100,00',
      'Costo c/u: Bs 100,00 ÷ 48 u = Bs 2,0833',
      'Sin stock antes: el costo promedio queda en el de este lote, Bs 2,0833',
    ]);
  });

  test('loose units need no division; negative stock carries no value', () {
    final lot = LooseUnitsLot(units: 20, unitPrice: const Money(50));
    expect(linesFor(lot, const StockState(units: -2, avgCost: UnitCost(4000))), [
      'Total: 20 u × Bs 0,50 = Bs 10,00',
      'Stock negativo (-2 u): no tiene valor, el costo promedio queda en el '
          'de este lote, Bs 0,5000',
    ]);
  });

  group('product', () {
    Product candy({int stock = 60, int cost = 20400}) => Product.create(
          name: 'Snickers',
          unitsPerBox: 24,
          suggestedPriceUnit: const Money(300),
          suggestedPriceBox: const Money(6500),
        ).copyWith(stockUnits: stock, avgCost: UnitCost(cost));

    test('stock value, how the average moves, profit per unit and per box',
        () {
      expect(productCostFormulaLines(candy()), [
        'Valor en stock = stock × costo promedio = 60 u × Bs 2,0400 = '
            'Bs 122,40',
        'Cada compra recalcula el promedio: (stock × costo actual + total de '
            'la compra) ÷ (stock + unidades compradas). Ventas y bajas no lo '
            'cambian: salen a este costo.',
        'Ganancia por unidad = precio − costo = Bs 3,00 − Bs 2,0400 = '
            'Bs 0,96 (32%)',
        'Ganancia por caja = precio − costo = Bs 65,00 − 24 u × Bs 2,0400 = '
            'Bs 65,00 − Bs 48,96 = Bs 16,04 (25%)',
      ]);
    });

    test('sold out keeps the cost but has no stock value line', () {
      final lines = productCostFormulaLines(candy(stock: 0));
      expect(lines.first, startsWith('Cada compra recalcula'));
      expect(lines, hasLength(3));
    });

    test('never bought', () {
      expect(productCostFormulaLines(candy(stock: 0, cost: 0)), [
        'Sin compras todavía: el costo promedio sale de la primera compra '
            '(total pagado ÷ unidades).',
      ]);
    });
  });
}
