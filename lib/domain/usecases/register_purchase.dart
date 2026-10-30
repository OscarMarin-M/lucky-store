import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/util/clock.dart';
import '../costing/cost_strategy.dart';
import '../entities/purchase.dart';
import '../purchasing/purchase_lot.dart';
import '../repositories/document_repositories.dart';
import '../repositories/product_repository.dart';
import 'inventory_ledger.dart';

class PurchaseLineInput {
  const PurchaseLineInput({required this.productId, required this.lot});

  final String productId;

  /// How it was bought (box or loose units); already validated.
  final PurchaseLot lot;
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
        final lot = input.lot;
        final effect = await ledger.purchase(
          input.productId,
          units: lot.unitsBase,
          total: lot.lineTotal,
        );
        built.add(PurchaseLine(
          id: newId(),
          createdAt: now,
          updatedAt: now,
          purchaseId: purchaseId,
          productId: input.productId,
          quantity: lot.quantity,
          presentation: lot.presentation,
          unitsBase: effect.unitsBase,
          lineTotal: lot.lineTotal,
          unitCost: effect.unitCost,
          unitsPerBox: lot.unitsPerBox,
          expiryFrom: lot.expiryFrom,
          expiryTo: lot.expiryTo,
          lotCode: lot.lotCode,
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
