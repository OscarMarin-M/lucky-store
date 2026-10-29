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
  });

  final DateTime date;
  final String? notes;
  final Money total;
  final Money profit;
  final List<SaleLine> lines;
}
