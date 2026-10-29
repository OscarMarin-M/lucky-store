import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../core/quantity/presentation.dart';
import 'base_entity.dart';

/// Why stock left without a sale.
///
/// Gifts given as a promotion are NOT adjustments: they are a sale line at
/// price 0, so their cost counts against the profit of that sale.
/// The reason is stored by name: do not rename without a migration.
enum AdjustmentReason {
  /// Merma: loss of product.
  shrinkage,

  /// Producto vencido.
  expired,

  /// Consumo propio (taken by the owner or staff).
  ownUse,

  other,
}

/// Units taken out of inventory without a sale. The loss is valued at the
/// average cost of that moment and frozen, so it can be added to the
/// profit/loss reports later.
class StockAdjustment extends BaseEntity {
  const StockAdjustment({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.productId,
    required this.date,
    required this.quantity,
    required this.presentation,
    required this.unitsBase,
    required this.reason,
    this.notes,
    required this.unitCost,
    required this.costTotal,
  });

  final String productId;
  final DateTime date;
  final int quantity;
  final Presentation presentation;
  final int unitsBase;
  final AdjustmentReason reason;
  final String? notes;

  /// Average cost per base unit when the units were written off.
  final UnitCost unitCost;

  /// What the written-off units had cost, i.e. the loss.
  final Money costTotal;
}
