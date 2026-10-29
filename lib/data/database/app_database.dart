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
  tables: [Products, Purchases, PurchaseLines, Sales, SaleLines, StockAdjustments],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Production database (file on the device).
  AppDatabase.persistent() : super(driftDatabase(name: 'lucky_store'));

  /// Bump on every schema change, add the step in [migration] and dump the
  /// new schema with `dart run drift_dev schema dump` (see drift_schemas/).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 is the first version: nothing to migrate yet.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
