import 'package:drift/drift.dart';

import '../../../core/quantity/presentation.dart';
import 'base_columns.dart';
import 'products_table.dart';

@DataClassName('SaleRow')
@TableIndex(name: 'sales_date_idx', columns: {#date})
class Sales extends Table with BaseColumns {
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  IntColumn get totalCents => integer()();
  IntColumn get profitCents => integer()();
}

@DataClassName('SaleLineRow')
@TableIndex(name: 'sale_lines_sale_idx', columns: {#saleId})
@TableIndex(name: 'sale_lines_product_idx', columns: {#productId})
class SaleLines extends Table with BaseColumns {
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();
  TextColumn get presentation => textEnum<Presentation>()();
  IntColumn get unitsBase => integer()();

  /// Price charged per presentation, in centavos.
  IntColumn get unitPriceCents => integer()();

  /// Suggested price per presentation when the sale was made.
  IntColumn get suggestedUnitPriceCents => integer()();
  IntColumn get lineTotalCents => integer()();

  /// Average cost per base unit at the time of the sale, 1/10.000 Bs.
  IntColumn get costAtSaleRaw => integer()();
  IntColumn get costTotalCents => integer()();
  IntColumn get profitCents => integer()();
}

/// v4: costs of an order that are not products (labor, printing...). Their
/// sum is already subtracted from `sales.profit_cents`.
@DataClassName('SaleExtraCostRow')
@TableIndex(name: 'sale_extra_costs_sale_idx', columns: {#saleId})
class SaleExtraCosts extends Table with BaseColumns {
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get concept => text()();
  IntColumn get amountCents => integer()();
}
