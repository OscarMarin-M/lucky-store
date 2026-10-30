import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/repositories/drift_product_repository.dart';
import '../data/repositories/drift_purchase_repository.dart';
import '../data/repositories/drift_sale_repository.dart';
import '../data/repositories/drift_stock_adjustment_repository.dart';
import '../domain/costing/cost_strategy.dart';
import '../domain/costing/weighted_average_cost_strategy.dart';
import '../domain/entities/product.dart';
import '../domain/entities/purchase.dart';
import '../domain/entities/sale.dart';
import '../domain/entities/stock_adjustment.dart';
import '../domain/repositories/document_repositories.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/usecases/inventory_ledger.dart';
import '../domain/usecases/register_purchase.dart';
import '../domain/usecases/register_sale.dart';
import '../domain/usecases/register_stock_adjustment.dart';

/// Composition root: the only place that knows which implementation backs
/// each interface. The UI reads providers and never touches Drift. Tests
/// override [appDatabaseProvider] with an in-memory database.

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.persistent();
  ref.onDispose(db.close);
  return db;
});

// --- Repositories ---------------------------------------------------------

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => DriftProductRepository(ref.watch(appDatabaseProvider)),
);

final purchaseRepositoryProvider = Provider<PurchaseRepository>(
  (ref) => DriftPurchaseRepository(ref.watch(appDatabaseProvider)),
);

final saleRepositoryProvider = Provider<SaleRepository>(
  (ref) => DriftSaleRepository(ref.watch(appDatabaseProvider)),
);

final stockAdjustmentRepositoryProvider = Provider<StockAdjustmentRepository>(
  (ref) => DriftStockAdjustmentRepository(ref.watch(appDatabaseProvider)),
);

final transactionRunnerProvider = Provider<TransactionRunner>(
  (ref) => DriftTransactionRunner(ref.watch(appDatabaseProvider)),
);

// --- Business rules -------------------------------------------------------

/// Swap this one to change the costing method (e.g. FIFO later).
final costStrategyProvider = Provider<CostStrategy>(
  (ref) => const WeightedAverageCostStrategy(),
);

/// Business parameters (negative stock, ...). Becomes a persisted setting
/// when the settings screen exists.
final inventoryPolicyProvider = Provider<InventoryPolicy>(
  (ref) => const InventoryPolicy(),
);

// --- Use cases ------------------------------------------------------------

final registerPurchaseProvider = Provider<RegisterPurchase>(
  (ref) => RegisterPurchase(
    products: ref.watch(productRepositoryProvider),
    purchases: ref.watch(purchaseRepositoryProvider),
    transactions: ref.watch(transactionRunnerProvider),
    costStrategy: ref.watch(costStrategyProvider),
    policy: ref.watch(inventoryPolicyProvider),
  ),
);

final registerSaleProvider = Provider<RegisterSale>(
  (ref) => RegisterSale(
    products: ref.watch(productRepositoryProvider),
    sales: ref.watch(saleRepositoryProvider),
    transactions: ref.watch(transactionRunnerProvider),
    costStrategy: ref.watch(costStrategyProvider),
    policy: ref.watch(inventoryPolicyProvider),
  ),
);

final registerStockAdjustmentProvider = Provider<RegisterStockAdjustment>(
  (ref) => RegisterStockAdjustment(
    products: ref.watch(productRepositoryProvider),
    adjustments: ref.watch(stockAdjustmentRepositoryProvider),
    transactions: ref.watch(transactionRunnerProvider),
    costStrategy: ref.watch(costStrategyProvider),
    policy: ref.watch(inventoryPolicyProvider),
  ),
);

// --- Live data for screens ------------------------------------------------

/// Write-offs of one product, newest first.
final productAdjustmentsProvider =
    StreamProvider.family<List<StockAdjustment>, String>(
  (ref, productId) => ref
      .watch(stockAdjustmentRepositoryProvider)
      .watchAll()
      .map((all) => all.where((a) => a.productId == productId).toList()),
);

/// Active products, ordered by name, refreshed on every change.
final productsProvider = StreamProvider<List<Product>>(
  (ref) => ref.watch(productRepositoryProvider).watchAll(),
);

/// Every product by id, deleted ones included: old documents must still show
/// the name of a product that no longer exists.
final productsByIdProvider = FutureProvider<Map<String, Product>>((ref) async {
  await ref.watch(productsProvider.future); // refresh when products change
  final all = await ref
      .watch(productRepositoryProvider)
      .getAll(includeDeleted: true);
  return {for (final p in all) p.id: p};
});

final purchasesProvider = StreamProvider<List<Purchase>>(
  (ref) => ref.watch(purchaseRepositoryProvider).watchAll(),
);

final salesProvider = StreamProvider<List<Sale>>(
  (ref) => ref.watch(saleRepositoryProvider).watchAll(),
);

final stockAdjustmentsProvider = StreamProvider<List<StockAdjustment>>(
  (ref) => ref.watch(stockAdjustmentRepositoryProvider).watchAll(),
);
