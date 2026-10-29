import 'package:drift/drift.dart';

import '../../../core/quantity/presentation.dart';
import 'base_columns.dart';
import 'products_table.dart';

@DataClassName('PurchaseRow')
@TableIndex(name: 'purchases_date_idx', columns: {#date})
class Purchases extends Table with BaseColumns {
  DateTimeColumn get date => dateTime()();
  TextColumn get supplier => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get totalCents => integer()();
}

@DataClassName('PurchaseLineRow')
@TableIndex(name: 'purchase_lines_purchase_idx', columns: {#purchaseId})
@TableIndex(name: 'purchase_lines_product_idx', columns: {#productId})
class PurchaseLines extends Table with BaseColumns {
  TextColumn get purchaseId => text().references(Purchases, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();
  TextColumn get presentation => textEnum<Presentation>()();

  /// [quantity] converted to base units.
  IntColumn get unitsBase => integer()();
  IntColumn get lineTotalCents => integer()();

  /// Cost per base unit of this purchase, 1/10.000 Bs.
  IntColumn get unitCostRaw => integer()();
}
