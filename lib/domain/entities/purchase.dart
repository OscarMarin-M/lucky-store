import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../core/quantity/presentation.dart';
import 'base_entity.dart';

class PurchaseLine extends BaseEntity {
  const PurchaseLine({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
    required this.presentation,
    required this.unitsBase,
    required this.lineTotal,
    required this.unitCost,
    this.unitsPerBox,
    this.expiryFrom,
    this.expiryTo,
    this.lotCode,
  });

  final String purchaseId;
  final String productId;

  /// Quantity as the user typed it, in [presentation].
  final int quantity;
  final Presentation presentation;

  /// [quantity] converted to base units.
  final int unitsBase;

  /// What was paid for the whole line.
  final Money lineTotal;

  /// What each base unit cost in this purchase (`lineTotal / unitsBase`).
  final UnitCost unitCost;

  /// Box size of this lot (suppliers differ); null for loose units.
  final int? unitsPerBox;

  /// Expiry range of the lot: a box has one date (from == to), loose units
  /// bought informally may span several. Null when not recorded.
  final DateTime? expiryFrom;
  final DateTime? expiryTo;

  /// Code printed on the box, if the owner typed it.
  final String? lotCode;
}

class Purchase extends BaseEntity {
  const Purchase({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.date,
    this.supplier,
    this.notes,
    required this.total,
    required this.lines,
  });

  final DateTime date;
  final String? supplier;
  final String? notes;
  final Money total;
  final List<PurchaseLine> lines;
}
