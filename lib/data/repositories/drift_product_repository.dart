import 'package:drift/drift.dart';

import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../database/app_database.dart';
import 'drift_crud_repository.dart';

class DriftProductRepository
    extends DriftCrudRepository<$ProductsTable, ProductRow, Product>
    implements ProductRepository {
  DriftProductRepository(AppDatabase db, {super.clock})
      : super(db, db.products);

  @override
  List<OrderingTerm Function($ProductsTable)> get defaultOrder =>
      [(t) => OrderingTerm.asc(t.name)];

  @override
  Product fromRow(ProductRow row) => Product(
        id: row.id,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
        name: row.name,
        sku: row.sku,
        unitsPerBox: row.unitsPerBox,
        stockUnits: row.stockUnits,
        avgCost: UnitCost(row.avgCostRaw),
        suggestedPriceUnit: Money(row.suggestedPriceUnitCents),
        suggestedPriceBox: row.suggestedPriceBoxCents == null
            ? null
            : Money(row.suggestedPriceBoxCents!),
        minStockUnits: row.minStockUnits,
        isActive: row.isActive,
      );

  @override
  Insertable<ProductRow> toInsertable(Product p) => ProductsCompanion(
        id: Value(p.id),
        createdAt: Value(p.createdAt),
        updatedAt: Value(p.updatedAt),
        deletedAt: Value(p.deletedAt),
        name: Value(p.name),
        sku: Value(p.sku),
        unitsPerBox: Value(p.unitsPerBox),
        stockUnits: Value(p.stockUnits),
        avgCostRaw: Value(p.avgCost.raw),
        suggestedPriceUnitCents: Value(p.suggestedPriceUnit.cents),
        suggestedPriceBoxCents: Value(p.suggestedPriceBox?.cents),
        minStockUnits: Value(p.minStockUnits),
        isActive: Value(p.isActive),
      );

  @override
  Product touch(Product entity, DateTime now) =>
      entity.copyWith(updatedAt: now);

  @override
  Future<List<Product>> search(String query) async {
    final pattern = '%${query.trim().toLowerCase()}%';
    final rows = await (selectRows()
          ..where((t) => t.name.lower().like(pattern) | t.sku.lower().like(pattern)))
        .get();
    return rows.map(fromRow).toList();
  }

  @override
  Future<void> updateInventory(
    String productId, {
    required int stockUnits,
    required UnitCost avgCost,
  }) async {
    final updated = await (db.update(db.products)
          ..where((t) => t.id.equals(productId)))
        .write(ProductsCompanion(
      stockUnits: Value(stockUnits),
      avgCostRaw: Value(avgCost.raw),
      updatedAt: Value(DateTime.now()),
    ));
    if (updated == 0) throw EntityNotFoundException('Producto', productId);
  }
}
