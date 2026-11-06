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

  /// v8. Email of the account that registered it (see the entity).
  TextColumn get registeredBy => text().nullable()();

  /// v9. Who voided it and why. A voided document has `deleted_at` set:
  /// it stays visible in the history but counts nowhere.
  TextColumn get voidedBy => text().nullable()();
  TextColumn get voidReason => text().nullable()();
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

  // --- v2: each line is a lot ---

  /// Size of the pack of this lot (box or bag, see `presentation`; the
  /// column keeps its v2 name); null for loose units.
  IntColumn get unitsPerBox => integer().nullable()();

  /// Expiry range (a box has from == to). Drives "por vencer" alerts.
  DateTimeColumn get expiryFrom => dateTime().nullable()();
  DateTimeColumn get expiryTo => dateTime().nullable()();
  TextColumn get lotCode => text().nullable()();
}
