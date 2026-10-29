import '../../core/quantity/presentation.dart';
import '../../core/util/clock.dart';
import '../costing/cost_strategy.dart';
import '../entities/stock_adjustment.dart';
import '../repositories/document_repositories.dart';
import '../repositories/product_repository.dart';
import 'inventory_ledger.dart';

/// Writes units off the inventory without a sale (merma, vencido, consumo
/// propio, otros).
/// The loss is valued at the current average cost.
class RegisterStockAdjustment {
  RegisterStockAdjustment({
    required ProductRepository products,
    required StockAdjustmentRepository adjustments,
    required TransactionRunner transactions,
    required CostStrategy costStrategy,
    InventoryPolicy policy = const InventoryPolicy(),
    Clock clock = DateTime.now,
  })  : _products = products,
        _adjustments = adjustments,
        _transactions = transactions,
        _strategy = costStrategy,
        _policy = policy,
        _clock = clock;

  final ProductRepository _products;
  final StockAdjustmentRepository _adjustments;
  final TransactionRunner _transactions;
  final CostStrategy _strategy;
  final InventoryPolicy _policy;
  final Clock _clock;

  Future<StockAdjustment> call({
    required String productId,
    required int quantity,
    required Presentation presentation,
    required AdjustmentReason reason,
    DateTime? date,
    String? notes,
  }) {
    return _transactions.run(() async {
      final now = _clock();
      final ledger = InventoryLedger(_products, _strategy, _policy);
      final effect = await ledger.outflow(
        productId,
        quantity: quantity,
        presentation: presentation,
      );

      final adjustment = await _adjustments.save(StockAdjustment(
        id: newId(),
        createdAt: now,
        updatedAt: now,
        productId: productId,
        date: date ?? now,
        quantity: quantity,
        presentation: presentation,
        unitsBase: effect.unitsBase,
        reason: reason,
        notes: notes,
        unitCost: effect.unitCost,
        costTotal: effect.totalCost,
      ));
      await ledger.flush();
      return adjustment;
    });
  }
}
