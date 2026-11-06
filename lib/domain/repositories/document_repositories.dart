import '../../core/money/money.dart';
import '../entities/purchase.dart';
import '../entities/sale.dart';
import '../entities/stock_adjustment.dart';

/// Runs [action] atomically: if anything throws, nothing is persisted.
abstract interface class TransactionRunner {
  Future<T> run<T>(Future<T> Function() action);
}

/// Recomputes stock and average cost of every product from the documents
/// that still count (e.g. after one is voided). Implemented by the
/// `InventoryRebuilder` of the sync.
abstract interface class InventoryReplayer {
  Future<void> replay();
}

abstract interface class PurchaseRepository {
  /// Stores the purchase and its lines.
  Future<Purchase> save(Purchase purchase);
  Future<Purchase?> getById(String id);
  Future<List<Purchase>> getAll({DateTime? from, DateTime? to});
  /// Newest first. [includeVoided] adds the voided ones (the history shows
  /// them crossed out); every report leaves them out.
  Stream<List<Purchase>> watchAll({bool includeVoided = false});

  /// Voids the document: sets `deleted_at` (and `updated_at`, so it syncs)
  /// with who and why. Returns false if it does not exist or was already
  /// voided. Its lines are left as they are: everything that counts joins
  /// the header.
  Future<bool> markVoided(
    String id, {
    required DateTime at,
    String? by,
    String? reason,
  });
}

/// Profit summary of one product over a period.
class ProductProfit {
  const ProductProfit({
    required this.productId,
    required this.productName,
    required this.unitsSold,
    required this.revenue,
    required this.cost,
    required this.profit,
  });

  final String productId;
  final String productName;
  final int unitsSold;
  final Money revenue;
  final Money cost;
  final Money profit;
}

abstract interface class SaleRepository {
  Future<Sale> save(Sale sale);
  Future<Sale?> getById(String id);
  Future<List<Sale>> getAll({DateTime? from, DateTime? to});
  /// Newest first. [includeVoided] adds the voided ones (the history shows
  /// them crossed out); every report leaves them out.
  Stream<List<Sale>> watchAll({bool includeVoided = false});

  /// Voids the document: sets `deleted_at` (and `updated_at`, so it syncs)
  /// with who and why. Returns false if it does not exist or was already
  /// voided. Its lines are left as they are: everything that counts joins
  /// the header.
  Future<bool> markVoided(
    String id, {
    required DateTime at,
    String? by,
    String? reason,
  });

  /// Sales profit grouped by product, best first. This is the app's main
  /// question: how much is earned or lost per product.
  Future<List<ProductProfit>> profitByProduct({DateTime? from, DateTime? to});
}

abstract interface class StockAdjustmentRepository {
  Future<StockAdjustment> save(StockAdjustment adjustment);
  Future<List<StockAdjustment>> getAll({
    String? productId,
    DateTime? from,
    DateTime? to,
  });
  /// Newest first. [includeVoided] adds the voided ones (the history shows
  /// them crossed out); every report leaves them out.
  Stream<List<StockAdjustment>> watchAll({bool includeVoided = false});

  /// Voids the document: sets `deleted_at` (and `updated_at`, so it syncs)
  /// with who and why. Returns false if it does not exist or was already
  /// voided. Its lines are left as they are: everything that counts joins
  /// the header.
  Future<bool> markVoided(
    String id, {
    required DateTime at,
    String? by,
    String? reason,
  });
}
