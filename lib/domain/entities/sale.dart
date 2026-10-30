import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../core/quantity/presentation.dart';
import 'base_entity.dart';

/// One sold line. Everything that can change later (suggested price, average
/// cost) is frozen here, so history never moves when prices or costs do.
class SaleLine extends BaseEntity {
  const SaleLine({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.presentation,
    required this.unitsBase,
    required this.unitPrice,
    required this.suggestedUnitPrice,
    required this.lineTotal,
    required this.costAtSale,
    required this.costTotal,
    required this.profit,
  });

  final String saleId;
  final String productId;

  /// Quantity as sold, in [presentation].
  final int quantity;
  final Presentation presentation;
  final int unitsBase;

  /// Price actually charged per [presentation] (one box or one unit).
  final Money unitPrice;

  /// Suggested price per [presentation] at the time of the sale.
  final Money suggestedUnitPrice;

  /// `unitPrice * quantity`.
  final Money lineTotal;

  /// Average cost per base unit in force at the time of the sale.
  final UnitCost costAtSale;

  /// Cost of the [unitsBase] sold, rounded to centavos.
  final Money costTotal;

  /// `lineTotal - costTotal`; negative when selling at a loss.
  final Money profit;

  /// How much was taken off the suggested price in all (negative = charged
  /// more than suggested).
  Money get discount => (suggestedUnitPrice - unitPrice).times(quantity);
}

/// A cost of an order that is not a product: labor to assemble a promo box,
/// printing the package, a ribbon bought on the spot... It is not charged to
/// the customer (the price of the lines already covers it) and it lowers the
/// profit of that sale only.
class SaleExtraCost extends BaseEntity {
  const SaleExtraCost({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.saleId,
    required this.concept,
    required this.amount,
  });

  final String saleId;

  /// What it was, as the owner typed it ("Mano de obra").
  final String concept;
  final Money amount;
}

/// A sale or "pedido": several product lines plus optional extra costs.
class Sale extends BaseEntity {
  const Sale({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.date,
    this.notes,
    required this.total,
    required this.profit,
    required this.lines,
    this.extraCosts = const [],
  });

  final DateTime date;

  /// Free text; also names the order ("Caja San Valentín para Ana").
  final String? notes;

  /// What the customer paid: the sum of the lines.
  final Money total;

  /// Lines profit minus [extraCosts]: what this sale really left.
  final Money profit;
  final List<SaleLine> lines;
  final List<SaleExtraCost> extraCosts;

  Money get extraCostsTotal => extraCosts.map((c) => c.amount).sum;

  /// Profit of the products alone, before the extra costs.
  Money get linesProfit => lines.map((l) => l.profit).sum;
}
