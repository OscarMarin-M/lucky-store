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

  /// [usual] defaults to the lot's own pack size: no size note.
  List<FormulaStep> stepsFor(PurchaseLot lot, StockState before, {int? usual}) =>
      purchaseCostSteps(
        lot,
        before: before,
        usualPackSize: usual ?? lot.unitsPerBox,
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
      expect(_eq(steps[0]), 'Unidades: 2 cajas × 24 u = 48 u');
      expect(_eq(steps[1]), 'Total: 2 cajas × Bs 50,00 = Bs 100,00');
      expect(_eq(steps[2]), 'Costo por unidad: Bs 100,00 ÷ 48 u = Bs 2,0833');
      expect(
        (steps[3] as FormulaNote).text,
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
    test('2 bags: units, total, cost per unit (v10)', () {
      final lot = BagLot(bags: 2, unitsPerBag: 30, pricePerBag: const Money(2400));
      final steps = stepsFor(lot, StockState.empty);
      expect(_eq(steps[0]), 'Unidades: 2 bolsas × 30 u = 60 u');
      expect(_eq(steps[1]), 'Total: 2 bolsas × Bs 24,00 = Bs 48,00');
      expect((steps[1] as Equation).right.label, 'precio bolsa');
      expect(_eq(steps[2]), 'Costo por unidad: Bs 48,00 ÷ 60 u = Bs 0,8000');
    });

    test('a bag of another size than the product says which count is used',
        () {
      final lot = BagLot(bags: 1, unitsPerBag: 25, pricePerBag: const Money(2000));
      final other = stepsFor(lot, StockState.empty, usual: 30)
          .whereType<FormulaNote>()
          .first
          .text;
      expect(other, contains('Esta bolsa trae 25 u y el producto usa 30 u'));
      expect(other, contains('al vender "1 bolsa" se descuentan 30 u'));

      final none = purchaseCostSteps(
        lot,
        before: StockState.empty,
        after: strategy.applyPurchase(StockState.empty, units: 25, total: lot.lineTotal),
      ).whereType<FormulaNote>().first.text;
      expect(none, startsWith('El producto no tiene unidades por bolsa'));

      final box = BoxLot(boxes: 1, unitsPerBox: 12, pricePerBox: const Money(1200));
      expect(
        stepsFor(box, StockState.empty, usual: 1).whereType<FormulaNote>().first.text,
        startsWith('El producto no tiene unidades por caja'),
        reason: 'a box size of 1 = no boxes',
      );
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
      expect(
        (steps[1] as FormulaNote).text,
        startsWith('Stock: 60 u = 2 cajas de 24 u + 12 u sueltas.'),
      );

      final unit = steps[2] as PriceSplit;
      expect(unit.cost, const Money(204));
      expect(unit.profit, const Money(96));
      expect(unit.marginPercent!.round(), 32);

      final box = steps[3] as PriceSplit;
      expect(box.title, 'Por caja (24 u)');
      expect(box.costDetail, '24 u × Bs 2,0400');
      expect(box.cost, const Money(4896));
      expect(box.profit, const Money(1604));
      expect(
        (steps.last as FormulaNote).text,
        contains('ganancia = precio del empaque − unidades × costo promedio'),
      );
    });

    test('a box priced below its cost shows a loss', () {
      final box = productCostSteps(candy(boxPrice: 4000))
          .whereType<PriceSplit>()
          .last;
      expect(box.profit, const Money(-896));
    });

    test('a bagged product explains its stock in bags (v10)', () {
      final p = Product.create(
        name: 'Skittles',
        suggestedPriceUnit: const Money(100),
        unitsPerBag: 30,
      ).copyWith(stockUnits: 85, avgCost: const UnitCost(6000));
      final steps = productCostSteps(p);
      expect(
        (steps[1] as FormulaNote).text,
        'Stock: 85 u = 2 bolsas de 30 u + 25 u sueltas. Todo se guarda en '
        'unidades: vender unidades sueltas abre una bolsa, y las bolsas se '
        'cuentan de 30 u aunque alguna compra haya traído otra cantidad.',
      );
      final bag = steps.whereType<PriceSplit>().last;
      expect(bag.title, 'Por bolsa (30 u)');
      expect(bag.cost, const Money(1800)); // 30 × 0,60
    });

    test('sold out has no stock value; never bought only explains', () {
      expect(productCostSteps(candy(stock: 0)).first, isA<PriceSplit>());
      final never = productCostSteps(candy(stock: 0, cost: 0));
      expect(never.single, isA<FormulaNote>());
    });
  });
}
