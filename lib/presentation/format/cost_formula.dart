import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../core/quantity/presentation.dart';
import '../../domain/costing/cost_strategy.dart';
import '../../domain/entities/product.dart';
import '../../domain/purchasing/purchase_lot.dart';

/// The arithmetic behind the cost figures, as steps that
/// `common/formula_box.dart` draws (equations, bars). Built with the real
/// numbers so the owner can check them by hand; the final figure always
/// comes from the cost strategy or the product, so the drawing can never
/// disagree with what is stored.
sealed class FormulaStep {
  const FormulaStep();
}

/// A figure and what it means: `Bs 72,00` / `precio caja`.
class Term {
  const Term(this.value, this.label);

  final String value;
  final String label;
}

/// `left op right = result`, e.g. `Bs 72,00 ÷ 36 u = Bs 2,0000`.
class Equation extends FormulaStep {
  const Equation(this.title, this.left, this.op, this.right, this.result);

  final String title;
  final Term left;
  final String op;
  final Term right;
  final Term result;
}

/// The weighted average of a purchase: the units already held and the lot
/// pooled together, then the pooled value split over all the units.
class AverageMix extends FormulaStep {
  const AverageMix({
    required this.heldUnits,
    required this.heldCost,
    required this.lotUnits,
    required this.lotCost,
    required this.lotValue,
    required this.newCost,
  });

  final int heldUnits;
  final UnitCost heldCost;
  final int lotUnits;
  final UnitCost lotCost;
  final Money lotValue;
  final UnitCost newCost;

  Money get heldValue => heldCost.totalFor(heldUnits);
  int get totalUnits => heldUnits + lotUnits;
  Money get totalValue => heldValue + lotValue;

  Equation get result => Equation(
    'Nuevo costo promedio',
    Term(totalValue.format(), 'valor total'),
    '÷',
    Term('$totalUnits u', 'unidades'),
    Term(newCost.format(), 'c/u'),
  );
}

/// A selling price split into what it costs and what it leaves.
class PriceSplit extends FormulaStep {
  const PriceSplit({
    required this.title,
    required this.price,
    required this.cost,
    this.costDetail,
  });

  final String title;
  final Money price;
  final Money cost;

  /// How [cost] was obtained when it is not obvious (`24 u × Bs 2,0400`).
  final String? costDetail;

  Money get profit => price - cost;

  /// Profit over price in percent; null for a price of 0.
  double? get marginPercent =>
      price.cents == 0 ? null : profit.cents * 100 / price.cents;
}

/// A sentence for what has no numbers (no stock, how ventas affect it).
class FormulaNote extends FormulaStep {
  const FormulaNote(this.text);

  final String text;
}

/// How one lot of a purchase gets its unit cost and moves the product's
/// average. [before] is the stock before this lot and [after] what the cost
/// strategy computed with it. [usualPackSize] is the product's own size for
/// the lot's pack (null: the product does not define it), to explain a lot
/// that came with another count.
List<FormulaStep> purchaseCostSteps(
  PurchaseLot lot, {
  required StockState before,
  required StockState after,
  int? usualPackSize,
}) {
  final units = lot.unitsBase;
  final steps = <FormulaStep?>[
    // Boxes and bags enter stock as units: show the conversion when there is
    // more than one pack (for one, the division below already shows it).
    if (lot case PackLot(:final packs, :final unitsPerPack) when packs > 1)
      Equation(
        'Unidades',
        Term('$packs ${lot.presentation.nameFor(packs)}', 'cantidad'),
        '×',
        Term('$unitsPerPack u', 'por ${lot.presentation.nameFor(1)}'),
        Term('$units u', 'al stock'),
      ),
    // A single pack's total is just its price: no step for it.
    switch (lot) {
      PackLot(:final packs, :final pricePerPack) when packs > 1 => Equation(
        'Total',
        Term('$packs ${lot.presentation.nameFor(packs)}', 'cantidad'),
        '×',
        Term(pricePerPack.format(), _packPriceLabel(lot)),
        Term(lot.lineTotal.format(), 'total'),
      ),
      PackLot() => null,
      LooseUnitsLot(:final unitPrice) => Equation(
        'Total',
        Term('$units u', 'cantidad'),
        '×',
        Term(unitPrice.format(), 'precio c/u'),
        Term(lot.lineTotal.format(), 'total'),
      ),
    },
    // Loose units are typed at their unit price: nothing to divide.
    if (lot is PackLot)
      Equation(
        'Costo por unidad',
        Term(
          lot.lineTotal.format(),
          lot.packs > 1 ? 'total' : _packPriceLabel(lot),
        ),
        '÷',
        Term('$units u', 'unidades'),
        Term(lot.unitCost.format(), 'c/u'),
      ),
  ].whereType<FormulaStep>().toList();

  if (lot is PackLot) {
    final note = _packSizeNote(lot, usualPackSize);
    if (note != null) steps.add(FormulaNote(note));
  }

  // Negative stock (sold offline before buying) carries no value, like in
  // the strategy: the lot alone sets the cost.
  final held = before.units;
  if (held <= 0) {
    steps.add(
      FormulaNote(
        held == 0
            ? 'No había stock: el costo promedio queda en el de este lote, '
                  '${after.avgCost.format()}.'
            : 'El stock era negativo ($held u) y no tiene valor: el costo '
                  'promedio queda en el de este lote, '
                  '${after.avgCost.format()}.',
      ),
    );
    return steps;
  }
  steps.add(
    AverageMix(
      heldUnits: held,
      heldCost: before.avgCost,
      lotUnits: units,
      lotCost: lot.unitCost,
      lotValue: lot.lineTotal,
      newCost: after.avgCost,
    ),
  );
  return steps;
}

/// "precio caja" / "precio bolsa".
String _packPriceLabel(PackLot lot) =>
    'precio ${lot.presentation.nameFor(1)}';

/// Why a lot's own pack size matters when it is not the product's usual
/// one: the cost uses the lot's count, the product's size stays as it is and
/// is what sales and the stock count use. Null when the sizes match.
String? _packSizeNote(PackLot lot, int? usual) {
  final one = lot.presentation.nameFor(1);
  final size = lot.unitsPerPack;
  if (usual == size) return null;
  // A box size of 1 means the product is not handled in boxes.
  if (usual == null || usual <= 1) {
    return 'El producto no tiene unidades por $one: el costo sale de las '
        '$size u de esta compra. Para vender o contar el stock en ${one}s, '
        'define las unidades por $one en la ficha del producto.';
  }
  return 'Esta $one trae $size u y el producto usa $usual u por $one: el '
      'costo sale de las $size u de esta compra. La ficha no cambia; al '
      'vender "1 $one" se descuentan $usual u.';
}

/// How the stock in units reads in packs, e.g. `85 u = 2 bolsas de 30 u +
/// 25 u sueltas`, and why loose sales "open" a pack. Null for products
/// without packs or without stock.
String? _stockInPacksNote(Product p) {
  final pack = p.hasBoxes
      ? Presentation.box
      : p.hasBags
          ? Presentation.bag
          : null;
  final size = pack == null ? null : p.unitsIn(pack);
  if (pack == null || size == null || size < 2 || p.stockUnits <= 0) {
    return null;
  }
  final packs = p.stockUnits ~/ size;
  final loose = p.stockUnits % size;
  final one = pack.nameFor(1);
  final breakdown = [
    if (packs > 0) '$packs ${pack.nameFor(packs)} de $size u',
    if (loose > 0) '$loose u sueltas',
  ].join(' + ');
  return 'Stock: ${p.stockUnits} u = $breakdown. Todo se guarda en '
      'unidades: vender unidades sueltas abre una $one, y las ${one}s se '
      'cuentan de $size u aunque alguna compra haya traído otra cantidad.';
}

/// The product's current figures: what its stock is worth and what one
/// unit / one box / one bag leaves at the suggested prices.
List<FormulaStep> productCostSteps(Product p) {
  final cost = p.avgCost;
  if (cost.raw == 0) {
    return const [
      FormulaNote(
        'Sin compras todavía: el costo promedio sale de la primera compra '
        '(total pagado ÷ unidades).',
      ),
    ];
  }
  final box = p.unitsPerBox;
  final stockNote = _stockInPacksNote(p);
  return [
    if (p.stockUnits > 0)
      Equation(
        'Valor en stock',
        Term('${p.stockUnits} u', 'stock'),
        '×',
        Term(cost.format(), 'costo prom.'),
        Term(p.stockValue.format(), 'valor'),
      ),
    if (stockNote != null) FormulaNote(stockNote),
    PriceSplit(
      title: 'Por unidad',
      price: p.suggestedPriceUnit,
      cost: cost.totalFor(1),
    ),
    if (box > 1)
      PriceSplit(
        title: 'Por caja ($box u)',
        price: p.suggestedPriceFor(Presentation.box),
        cost: cost.totalFor(box),
        costDetail: '$box u × ${cost.format()}',
      ),
    if (p.unitsPerBag case final bag?)
      PriceSplit(
        title: 'Por bolsa ($bag u)',
        price: p.suggestedPriceFor(Presentation.bag),
        cost: cost.totalFor(bag),
        costDetail: '$bag u × ${cost.format()}',
      ),
    const FormulaNote(
      'Cada compra recalcula el costo promedio: (stock × costo actual + total '
      'de la compra) ÷ (stock + unidades compradas). Ventas y bajas no lo '
      'cambian: salen a este costo.',
    ),
    if (p.hasBoxes || p.hasBags)
      const FormulaNote(
        'Cajas y bolsas no cambian el cálculo: se convierten a unidades '
        '(cantidad × unidades por empaque) y todo se calcula por unidad. '
        'Vender un empaque: ganancia = precio del empaque − unidades × costo '
        'promedio.',
      ),
  ];
}
