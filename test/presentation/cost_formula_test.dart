import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/domain/costing/cost_strategy.dart';
import 'package:lucky_store/domain/costing/weighted_average_cost_strategy.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/domain/purchasing/purchase_lot.dart';
import 'package:lucky_store/presentation/format/cost_formula.dart';

/// `title: a op b = c`, to compare equations in one line.
String _eq(FormulaStep s) {
  final e = s as Equation;
  return '${e.title}: ${e.left.value} ${e.op} ${e.right.value} = '
      '${e.result.value}';
}

void main() {
  const strategy = WeightedAverageCostStrategy();

  List<FormulaStep> stepsFor(PurchaseLot lot, StockState before) =>
      purchaseCostSteps(
        lot,
        before: before,
        after: strategy.applyPurchase(
          before,
          units: lot.unitsBase,
          total: lot.lineTotal,
        ),
      );

  group('purchase', () {
    test('a box of 36 mixed with 24 units in stock', () {
      final lot = BoxLot(
        boxes: 1,
        unitsPerBox: 36,
        pricePerBox: const Money(7200),
      );
      final steps = stepsFor(
        lot,
        const StockState(units: 24, avgCost: UnitCost(21000)),
      );
      expect(steps, hasLength(2), reason: 'one box: no "Total" step');
      expect(_eq(steps[0]), 'Costo por unidad: Bs 72,00 ÷ 36 u = Bs 2,0000');

      final mix = steps[1] as AverageMix;
      expect(mix.heldValue, const Money(5040)); // 24 × 2,10
      expect(mix.lotValue, const Money(7200));
      expect(
        _eq(mix.result),
        'Nuevo costo promedio: Bs 122,40 ÷ 60 u = Bs 2,0400',
      );
    });

    test('two boxes at a price that does not divide evenly', () {
      final lot = BoxLot(
        boxes: 2,
        unitsPerBox: 24,
        pricePerBox: const Money(5000),
      );
      final steps = stepsFor(lot, StockState.empty);
      expect(_eq(steps[0]), 'Total: 2 cajas × Bs 50,00 = Bs 100,00');
      expect(_eq(steps[1]), 'Costo por unidad: Bs 100,00 ÷ 48 u = Bs 2,0833');
      expect(
        (steps[2] as FormulaNote).text,
        'No había stock: el costo promedio queda en el de este lote, '
        'Bs 2,0833.',
      );
    });

    test('loose units need no division; negative stock carries no value', () {
      final lot = LooseUnitsLot(units: 20, unitPrice: const Money(50));
      final steps = stepsFor(
        lot,
        const StockState(units: -2, avgCost: UnitCost(4000)),
      );
      expect(steps, hasLength(2));
      expect(_eq(steps[0]), 'Total: 20 u × Bs 0,50 = Bs 10,00');
      expect((steps[1] as FormulaNote).text, contains('negativo (-2 u)'));
      expect((steps[1] as FormulaNote).text, endsWith('Bs 0,5000.'));
    });
  });

  group('product', () {
    Product candy({int stock = 60, int cost = 20400, int boxPrice = 6500}) =>
        Product.create(
          name: 'Snickers',
          unitsPerBox: 24,
          suggestedPriceUnit: const Money(300),
          suggestedPriceBox: Money(boxPrice),
        ).copyWith(stockUnits: stock, avgCost: UnitCost(cost));

    test('stock value and the price split per unit and per box', () {
      final steps = productCostSteps(candy());
      expect(_eq(steps[0]), 'Valor en stock: 60 u × Bs 2,0400 = Bs 122,40');

      final unit = steps[1] as PriceSplit;
      expect(unit.cost, const Money(204));
      expect(unit.profit, const Money(96));
      expect(unit.marginPercent!.round(), 32);

      final box = steps[2] as PriceSplit;
      expect(box.title, 'Por caja (24 u)');
      expect(box.costDetail, '24 u × Bs 2,0400');
      expect(box.cost, const Money(4896));
      expect(box.profit, const Money(1604));
      expect(steps.last, isA<FormulaNote>());
    });

    test('a box priced below its cost shows a loss', () {
      final box = productCostSteps(candy(boxPrice: 4000))[2] as PriceSplit;
      expect(box.profit, const Money(-896));
    });

    test('sold out has no stock value; never bought only explains', () {
      expect(productCostSteps(candy(stock: 0)).first, isA<PriceSplit>());
      final never = productCostSteps(candy(stock: 0, cost: 0));
      expect(never.single, isA<FormulaNote>());
    });
  });
}
