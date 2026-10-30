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

/// Something charged on an order that is not a product: assembling a promo
/// box, its packaging, printing... The customer pays it on top of the
/// products, and since it takes nothing from stock it is all profit.
class SaleExtraCharge extends BaseEntity {
  const SaleExtraCharge({
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

/// A sale or "pedido": several product lines plus optional extra charges.
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
    this.extraCharges = const [],
  });

  final DateTime date;

  /// Free text; also names the order ("Caja San Valentín para Ana").
  final String? notes;

  /// What the customer paid: the lines plus the [extraCharges].
  final Money total;

  /// Lines profit plus [extraCharges] (they have no cost).
  final Money profit;
  final List<SaleLine> lines;
  final List<SaleExtraCharge> extraCharges;

  Money get extraChargesTotal => extraCharges.map((c) => c.amount).sum;

  /// What the products alone were charged.
  Money get linesTotal => lines.map((l) => l.lineTotal).sum;

  /// Profit of the products alone, without the extra charges.
  Money get linesProfit => lines.map((l) => l.profit).sum;
}
