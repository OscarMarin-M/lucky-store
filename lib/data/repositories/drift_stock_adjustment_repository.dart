import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/repositories/document_repositories.dart';
import '../database/app_database.dart';

class DriftStockAdjustmentRepository implements StockAdjustmentRepository {
  DriftStockAdjustmentRepository(this._db);

  final AppDatabase _db;

  @override
  Future<StockAdjustment> save(StockAdjustment a) async {
    await _db.into(_db.stockAdjustments).insert(StockAdjustmentsCompanion(
          id: Value(a.id),
          createdAt: Value(a.createdAt),
          updatedAt: Value(a.updatedAt),
          deletedAt: Value(a.deletedAt),
          productId: Value(a.productId),
          date: Value(a.date),
          quantity: Value(a.quantity),
          presentation: Value(a.presentation),
          unitsBase: Value(a.unitsBase),
          reason: Value(a.reason),
          notes: Value(a.notes),
          unitCostRaw: Value(a.unitCost.raw),
          costTotalCents: Value(a.costTotal.cents),
        ));
    return a;
  }

  @override
  Future<List<StockAdjustment>> getAll({
    String? productId,
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = await _query(productId, from, to).get();
    return rows.map(_fromRow).toList();
  }

  @override
  Stream<List<StockAdjustment>> watchAll() =>
      _query(null, null, null).watch().map((rows) => rows.map(_fromRow).toList());

  SimpleSelectStatement<$StockAdjustmentsTable, StockAdjustmentRow> _query(
    String? productId,
    DateTime? from,
    DateTime? to,
  ) {
    return _db.select(_db.stockAdjustments)
      ..where((t) {
        var cond = t.deletedAt.isNull();
        if (productId != null) cond = cond & t.productId.equals(productId);
        if (from != null) cond = cond & t.date.isBiggerOrEqualValue(from);
        if (to != null) cond = cond & t.date.isSmallerThanValue(to);
        return cond;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
  }

  StockAdjustment _fromRow(StockAdjustmentRow r) => StockAdjustment(
        id: r.id,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
        productId: r.productId,
        date: r.date,
        quantity: r.quantity,
        presentation: r.presentation,
        unitsBase: r.unitsBase,
        reason: r.reason,
        notes: r.notes,
        unitCost: UnitCost(r.unitCostRaw),
        costTotal: Money(r.costTotalCents),
      );
}
