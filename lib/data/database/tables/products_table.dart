import 'package:drift/drift.dart';

import 'base_columns.dart';

@DataClassName('ProductRow')
@TableIndex(name: 'products_name_idx', columns: {#name})
@TableIndex(name: 'products_sku_idx', columns: {#sku})
class Products extends Table with BaseColumns {
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();

  /// Base units per box (1 = sold without boxes).
  IntColumn get unitsPerBox => integer().withDefault(const Constant(1))();

  /// Inventory in base units.
  IntColumn get stockUnits => integer().withDefault(const Constant(0))();

  /// Weighted average cost per base unit, 1/10.000 Bs.
  IntColumn get avgCostRaw => integer().withDefault(const Constant(0))();

  /// Suggested prices in centavos.
  IntColumn get suggestedPriceUnitCents =>
      integer().withDefault(const Constant(0))();
  IntColumn get suggestedPriceBoxCents => integer().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
