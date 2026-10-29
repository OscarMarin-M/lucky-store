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
