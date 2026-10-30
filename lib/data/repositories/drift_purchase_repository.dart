import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/repositories/document_repositories.dart';
import '../database/app_database.dart';

class DriftTransactionRunner implements TransactionRunner {
  DriftTransactionRunner(this._db);

  final AppDatabase _db;

  @override
  Future<T> run<T>(Future<T> Function() action) => _db.transaction(action);
}

class DriftPurchaseRepository implements PurchaseRepository {
  DriftPurchaseRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Purchase> save(Purchase p) => _db.transaction(() async {
        await _db.into(_db.purchases).insert(PurchasesCompanion(
              id: Value(p.id),
              createdAt: Value(p.createdAt),
              updatedAt: Value(p.updatedAt),
              deletedAt: Value(p.deletedAt),
              date: Value(p.date),
              supplier: Value(p.supplier),
              notes: Value(p.notes),
              totalCents: Value(p.total.cents),
            ));
        for (final l in p.lines) {
          await _db.into(_db.purchaseLines).insert(PurchaseLinesCompanion(
                id: Value(l.id),
                createdAt: Value(l.createdAt),
                updatedAt: Value(l.updatedAt),
                deletedAt: Value(l.deletedAt),
                purchaseId: Value(l.purchaseId),
                productId: Value(l.productId),
                quantity: Value(l.quantity),
                presentation: Value(l.presentation),
                unitsBase: Value(l.unitsBase),
                lineTotalCents: Value(l.lineTotal.cents),
                unitCostRaw: Value(l.unitCost.raw),
                unitsPerBox: Value(l.unitsPerBox),
                expiryFrom: Value(l.expiryFrom),
                expiryTo: Value(l.expiryTo),
                lotCode: Value(l.lotCode),
              ));
        }
        return p;
      });

  @override
  Future<Purchase?> getById(String id) async {
    final row = await (_db.select(_db.purchases)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;
    return (await _withLines([row])).single;
  }

  @override
  Future<List<Purchase>> getAll({DateTime? from, DateTime? to}) async {
    final rows = await _query(from, to).get();
    return _withLines(rows);
  }

  @override
  Stream<List<Purchase>> watchAll() =>
      _query(null, null).watch().asyncMap(_withLines);

  SimpleSelectStatement<$PurchasesTable, PurchaseRow> _query(
    DateTime? from,
    DateTime? to,
  ) {
    return _db.select(_db.purchases)
      ..where((t) {
        var cond = t.deletedAt.isNull();
        if (from != null) cond = cond & t.date.isBiggerOrEqualValue(from);
        if (to != null) cond = cond & t.date.isSmallerThanValue(to);
        return cond;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
  }

  Future<List<Purchase>> _withLines(List<PurchaseRow> headers) async {
    if (headers.isEmpty) return [];
    final lineRows = await (_db.select(_db.purchaseLines)
          ..where((t) =>
              t.purchaseId.isIn(headers.map((h) => h.id)) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
          ]))
        .get();
    final byPurchase = <String, List<PurchaseLine>>{};
    for (final r in lineRows) {
      byPurchase.putIfAbsent(r.purchaseId, () => []).add(PurchaseLine(
            id: r.id,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
            deletedAt: r.deletedAt,
            purchaseId: r.purchaseId,
            productId: r.productId,
            quantity: r.quantity,
            presentation: r.presentation,
            unitsBase: r.unitsBase,
            lineTotal: Money(r.lineTotalCents),
            unitCost: UnitCost(r.unitCostRaw),
            unitsPerBox: r.unitsPerBox,
            expiryFrom: r.expiryFrom,
            expiryTo: r.expiryTo,
            lotCode: r.lotCode,
          ));
    }
    return [
      for (final h in headers)
        Purchase(
          id: h.id,
          createdAt: h.createdAt,
          updatedAt: h.updatedAt,
          deletedAt: h.deletedAt,
          date: h.date,
          supplier: h.supplier,
          notes: h.notes,
          total: Money(h.totalCents),
          lines: byPurchase[h.id] ?? const [],
        ),
    ];
  }
}
