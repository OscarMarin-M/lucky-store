import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/quantity/presentation.dart';
import '../../core/util/clock.dart';
import '../costing/cost_strategy.dart';
import '../entities/purchase.dart';
import '../repositories/document_repositories.dart';
import '../repositories/product_repository.dart';
import 'inventory_ledger.dart';

class PurchaseLineInput {
  const PurchaseLineInput({
    required this.productId,
    required this.quantity,
    required this.presentation,
    required this.lineTotal,
  });

  final String productId;
  final int quantity;
  final Presentation presentation;

  /// Total paid for the whole line (not per unit).
  final Money lineTotal;
}

/// Registers a purchase: stores it and raises stock / recomputes the average
/// cost of each product, atomically.
class RegisterPurchase {
  RegisterPurchase({
    required ProductRepository products,
    required PurchaseRepository purchases,
    required TransactionRunner transactions,
    required CostStrategy costStrategy,
    InventoryPolicy policy = const InventoryPolicy(),
    Clock clock = DateTime.now,
  })  : _products = products,
        _purchases = purchases,
        _transactions = transactions,
        _strategy = costStrategy,
        _policy = policy,
        _clock = clock;

  final ProductRepository _products;
  final PurchaseRepository _purchases;
  final TransactionRunner _transactions;
  final CostStrategy _strategy;
  final InventoryPolicy _policy;
  final Clock _clock;

  Future<Purchase> call({
    DateTime? date,
    String? supplier,
    String? notes,
    required List<PurchaseLineInput> lines,
  }) {
    if (lines.isEmpty) throw const EmptyDocumentException();

    return _transactions.run(() async {
      final now = _clock();
      final purchaseId = newId();
      final ledger = InventoryLedger(_products, _strategy, _policy);

      final built = <PurchaseLine>[];
      for (final input in lines) {
        final effect = await ledger.purchase(
          input.productId,
          quantity: input.quantity,
          presentation: input.presentation,
          total: input.lineTotal,
        );
        built.add(PurchaseLine(
          id: newId(),
          createdAt: now,
          updatedAt: now,
          purchaseId: purchaseId,
          productId: input.productId,
          quantity: input.quantity,
          presentation: input.presentation,
          unitsBase: effect.unitsBase,
          lineTotal: input.lineTotal,
          unitCost: effect.unitCost,
        ));
      }

      final purchase = await _purchases.save(Purchase(
        id: purchaseId,
        createdAt: now,
        updatedAt: now,
        date: date ?? now,
        supplier: supplier,
        notes: notes,
        total: built.map((l) => l.lineTotal).sum,
        lines: built,
      ));
      await ledger.flush();
      return purchase;
    });
  }
}
