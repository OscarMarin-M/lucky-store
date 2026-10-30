import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/quantity/presentation.dart';
import '../../domain/entities/stock_adjustment.dart';
import 'tables/products_table.dart';
import 'tables/purchase_tables.dart';
import 'tables/sale_tables.dart';
import 'tables/stock_adjustments_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Purchases,
    PurchaseLines,
    Sales,
    SaleLines,
    SaleExtraCosts,
    StockAdjustments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Production database (file on the device).
  AppDatabase.persistent() : super(driftDatabase(name: 'lucky_store'));

  /// Bump on every schema change, add the step in [migration] and dump the
  /// new schema with `dart run drift_dev schema dump` (see drift_schemas/).
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Purchase lines become lots: box size, expiry range and code.
            await m.addColumn(purchaseLines, purchaseLines.unitsPerBox);
            await m.addColumn(purchaseLines, purchaseLines.expiryFrom);
            await m.addColumn(purchaseLines, purchaseLines.expiryTo);
            await m.addColumn(purchaseLines, purchaseLines.lotCode);
            // v1 box lines were converted with the product's box size;
            // recover it from what was stored so old lots show it too.
            await customStatement(
              "UPDATE purchase_lines SET units_per_box = units_base / quantity "
              "WHERE presentation = 'box' AND quantity > 0",
            );
          }
          if (from < 3) {
            // Optional minimum stock per product for the "stock bajo" alert.
            await m.addColumn(products, products.minStockUnits);
          }
          if (from < 4) {
            // Orders can carry costs that are not products.
            await m.createTable(saleExtraCosts);
            await m.createIndex(saleExtraCostsSaleIdx);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
