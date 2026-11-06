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
    await _db
        .into(_db.stockAdjustments)
        .insert(
          StockAdjustmentsCompanion(
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
            registeredBy: Value(a.registeredBy),
            voidedBy: Value(a.voidedBy),
            voidReason: Value(a.voidReason),
            unitCostRaw: Value(a.unitCost.raw),
            costTotalCents: Value(a.costTotal.cents),
          ),
        );
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
  Stream<List<StockAdjustment>> watchAll({bool includeVoided = false}) =>
      _query(
        null,
        null,
        null,
        includeVoided: includeVoided,
      ).watch().map((rows) => rows.map(_fromRow).toList());

  @override
  Future<bool> markVoided(
    String id, {
    required DateTime at,
    String? by,
    String? reason,
  }) async {
    final n =
        await (_db.update(
          _db.stockAdjustments,
        )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).write(
          StockAdjustmentsCompanion(
            deletedAt: Value(at),
            updatedAt: Value(at),
            voidedBy: Value(by),
            voidReason: Value(reason),
          ),
        );
    return n == 1;
  }

  SimpleSelectStatement<$StockAdjustmentsTable, StockAdjustmentRow> _query(
    String? productId,
    DateTime? from,
    DateTime? to, {
    bool includeVoided = false,
  }) {
    return _db.select(_db.stockAdjustments)
      ..where((t) {
        Expression<bool> cond = includeVoided
            ? const Constant(true)
            : t.deletedAt.isNull();
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
    registeredBy: r.registeredBy,
    voidedBy: r.voidedBy,
    voidReason: r.voidReason,
    unitCost: UnitCost(r.unitCostRaw),
    costTotal: Money(r.costTotalCents),
  );
}
