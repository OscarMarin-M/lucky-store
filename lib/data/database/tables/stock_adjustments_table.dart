import 'package:drift/drift.dart';

import '../../../core/quantity/presentation.dart';
import '../../../domain/entities/stock_adjustment.dart';
import 'base_columns.dart';
import 'products_table.dart';

@DataClassName('StockAdjustmentRow')
@TableIndex(name: 'stock_adjustments_product_idx', columns: {#productId})
@TableIndex(name: 'stock_adjustments_date_idx', columns: {#date})
class StockAdjustments extends Table with BaseColumns {
  TextColumn get productId => text().references(Products, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get quantity => integer()();
  TextColumn get presentation => textEnum<Presentation>()();
  IntColumn get unitsBase => integer()();
  TextColumn get reason => textEnum<AdjustmentReason>()();
  TextColumn get notes => text().nullable()();

  /// Average cost per base unit when written off, 1/10.000 Bs.
  IntColumn get unitCostRaw => integer()();
  IntColumn get costTotalCents => integer()();
}
