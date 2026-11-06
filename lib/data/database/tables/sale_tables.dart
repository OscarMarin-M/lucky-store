import 'package:drift/drift.dart';

import '../../../core/quantity/presentation.dart';
import 'base_columns.dart';
import 'products_table.dart';

@DataClassName('SaleRow')
@TableIndex(name: 'sales_date_idx', columns: {#date})
class Sales extends Table with BaseColumns {
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();

  /// v8. Email of the account that registered it (see the entity).
  TextColumn get registeredBy => text().nullable()();

  /// v9. Who voided it and why. A voided document has `deleted_at` set:
  /// it stays visible in the history but counts nowhere.
  TextColumn get voidedBy => text().nullable()();
  TextColumn get voidReason => text().nullable()();
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

/// v5 (was `sale_extra_costs` in v4): amounts of an order that are not
/// products (assembly, packaging...). Their effect is already included in
/// `sales.total_cents` and `sales.profit_cents`.
@DataClassName('SaleExtraChargeRow')
@TableIndex(name: 'sale_extra_charges_sale_idx', columns: {#saleId})
class SaleExtraCharges extends Table with BaseColumns {
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get concept => text()();
  IntColumn get amountCents => integer()();

  /// v7. True: the customer pays it on top of the products (adds to total
  /// and profit). False: the shop pays it (total unchanged, profit lowered).
  /// Every row from before v7 was charged to the customer.
  BoolColumn get paidByCustomer =>
      boolean().withDefault(const Constant(true))();
}
