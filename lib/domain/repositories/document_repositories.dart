import '../../core/money/money.dart';
import '../entities/purchase.dart';
import '../entities/sale.dart';
import '../entities/stock_adjustment.dart';

/// Runs [action] atomically: if anything throws, nothing is persisted.
abstract interface class TransactionRunner {
  Future<T> run<T>(Future<T> Function() action);
}

abstract interface class PurchaseRepository {
  /// Stores the purchase and its lines.
  Future<Purchase> save(Purchase purchase);
  Future<Purchase?> getById(String id);
  Future<List<Purchase>> getAll({DateTime? from, DateTime? to});
  Stream<List<Purchase>> watchAll();
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
  Stream<List<Sale>> watchAll();

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
  Stream<List<StockAdjustment>> watchAll();
}
