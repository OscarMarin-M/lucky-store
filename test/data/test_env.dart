import 'package:drift/native.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/data/repositories/drift_product_repository.dart';
import 'package:lucky_store/data/repositories/drift_purchase_repository.dart';
import 'package:lucky_store/data/repositories/drift_sale_repository.dart';
import 'package:lucky_store/data/repositories/drift_stock_adjustment_repository.dart';
import 'package:lucky_store/domain/costing/weighted_average_cost_strategy.dart';
import 'package:lucky_store/domain/usecases/inventory_ledger.dart';
import 'package:lucky_store/domain/usecases/register_purchase.dart';
import 'package:lucky_store/domain/usecases/register_sale.dart';
import 'package:lucky_store/domain/usecases/register_stock_adjustment.dart';

/// In-memory database wired with real repositories and use cases.
class TestEnv {
  TestEnv({InventoryPolicy policy = const InventoryPolicy()})
      : db = AppDatabase(NativeDatabase.memory()) {
    products = DriftProductRepository(db);
    purchases = DriftPurchaseRepository(db);
    sales = DriftSaleRepository(db);
    adjustments = DriftStockAdjustmentRepository(db);
    final tx = DriftTransactionRunner(db);
    const strategy = WeightedAverageCostStrategy();
    registerPurchase = RegisterPurchase(
      products: products,
      purchases: purchases,
      transactions: tx,
      costStrategy: strategy,
      policy: policy,
    );
    registerSale = RegisterSale(
      products: products,
      sales: sales,
      transactions: tx,
      costStrategy: strategy,
      policy: policy,
    );
    registerAdjustment = RegisterStockAdjustment(
      products: products,
      adjustments: adjustments,
      transactions: tx,
      costStrategy: strategy,
      policy: policy,
    );
  }

  final AppDatabase db;
  late final DriftProductRepository products;
  late final DriftPurchaseRepository purchases;
  late final DriftSaleRepository sales;
  late final DriftStockAdjustmentRepository adjustments;
  late final RegisterPurchase registerPurchase;
  late final RegisterSale registerSale;
  late final RegisterStockAdjustment registerAdjustment;

  Future<void> dispose() => db.close();
}
