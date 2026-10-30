import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/document_repositories.dart';
import '../database/app_database.dart';

class DriftSaleRepository implements SaleRepository {
  DriftSaleRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Sale> save(Sale s) => _db.transaction(() async {
        await _db.into(_db.sales).insert(SalesCompanion(
              id: Value(s.id),
              createdAt: Value(s.createdAt),
              updatedAt: Value(s.updatedAt),
              deletedAt: Value(s.deletedAt),
              date: Value(s.date),
              notes: Value(s.notes),
              totalCents: Value(s.total.cents),
              profitCents: Value(s.profit.cents),
            ));
        for (final l in s.lines) {
          await _db.into(_db.saleLines).insert(SaleLinesCompanion(
                id: Value(l.id),
                createdAt: Value(l.createdAt),
                updatedAt: Value(l.updatedAt),
                deletedAt: Value(l.deletedAt),
                saleId: Value(l.saleId),
                productId: Value(l.productId),
                quantity: Value(l.quantity),
                presentation: Value(l.presentation),
                unitsBase: Value(l.unitsBase),
                unitPriceCents: Value(l.unitPrice.cents),
                suggestedUnitPriceCents: Value(l.suggestedUnitPrice.cents),
                lineTotalCents: Value(l.lineTotal.cents),
                costAtSaleRaw: Value(l.costAtSale.raw),
                costTotalCents: Value(l.costTotal.cents),
                profitCents: Value(l.profit.cents),
              ));
        }
        for (final c in s.extraCharges) {
          await _db.into(_db.saleExtraCharges).insert(SaleExtraChargesCompanion(
                id: Value(c.id),
                createdAt: Value(c.createdAt),
                updatedAt: Value(c.updatedAt),
                deletedAt: Value(c.deletedAt),
                saleId: Value(c.saleId),
                concept: Value(c.concept),
                amountCents: Value(c.amount.cents),
              ));
        }
        return s;
      });

  @override
  Future<Sale?> getById(String id) async {
    final row = await (_db.select(_db.sales)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;
    return (await _withLines([row])).single;
  }

  @override
  Future<List<Sale>> getAll({DateTime? from, DateTime? to}) async {
    final rows = await _query(from, to).get();
    return _withLines(rows);
  }

  @override
  Stream<List<Sale>> watchAll() =>
      _query(null, null).watch().asyncMap(_withLines);

  @override
  Future<List<ProductProfit>> profitByProduct({
    DateTime? from,
    DateTime? to,
  }) async {
    final lines = _db.saleLines;
    final units = lines.unitsBase.sum();
    final revenue = lines.lineTotalCents.sum();
    final cost = lines.costTotalCents.sum();
    final profit = lines.profitCents.sum();

    final query = _db.selectOnly(lines).join([
      innerJoin(_db.sales, _db.sales.id.equalsExp(lines.saleId)),
      innerJoin(_db.products, _db.products.id.equalsExp(lines.productId)),
    ])
      ..addColumns([lines.productId, _db.products.name, units, revenue, cost, profit])
      ..where(() {
        var cond = lines.deletedAt.isNull() & _db.sales.deletedAt.isNull();
        if (from != null) cond = cond & _db.sales.date.isBiggerOrEqualValue(from);
        if (to != null) cond = cond & _db.sales.date.isSmallerThanValue(to);
        return cond;
      }())
      ..groupBy([lines.productId, _db.products.name])
      ..orderBy([OrderingTerm.desc(profit)]);

    final rows = await query.get();
    return [
      for (final r in rows)
        ProductProfit(
          productId: r.read(lines.productId)!,
          productName: r.read(_db.products.name)!,
          unitsSold: r.read(units) ?? 0,
          revenue: Money(r.read(revenue) ?? 0),
          cost: Money(r.read(cost) ?? 0),
          profit: Money(r.read(profit) ?? 0),
        ),
    ];
  }

  SimpleSelectStatement<$SalesTable, SaleRow> _query(
    DateTime? from,
    DateTime? to,
  ) {
    return _db.select(_db.sales)
      ..where((t) {
        var cond = t.deletedAt.isNull();
        if (from != null) cond = cond & t.date.isBiggerOrEqualValue(from);
        if (to != null) cond = cond & t.date.isSmallerThanValue(to);
        return cond;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
  }

  Future<List<Sale>> _withLines(List<SaleRow> headers) async {
    if (headers.isEmpty) return [];
    final lineRows = await (_db.select(_db.saleLines)
          ..where((t) =>
              t.saleId.isIn(headers.map((h) => h.id)) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
          ]))
        .get();
    final bySale = <String, List<SaleLine>>{};
    for (final r in lineRows) {
      bySale.putIfAbsent(r.saleId, () => []).add(SaleLine(
            id: r.id,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
            deletedAt: r.deletedAt,
            saleId: r.saleId,
            productId: r.productId,
            quantity: r.quantity,
            presentation: r.presentation,
            unitsBase: r.unitsBase,
            unitPrice: Money(r.unitPriceCents),
            suggestedUnitPrice: Money(r.suggestedUnitPriceCents),
            lineTotal: Money(r.lineTotalCents),
            costAtSale: UnitCost(r.costAtSaleRaw),
            costTotal: Money(r.costTotalCents),
            profit: Money(r.profitCents),
          ));
    }
    final extraRows = await (_db.select(_db.saleExtraCharges)
          ..where((t) =>
              t.saleId.isIn(headers.map((h) => h.id)) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
          ]))
        .get();
    final extrasBySale = <String, List<SaleExtraCharge>>{};
    for (final r in extraRows) {
      extrasBySale.putIfAbsent(r.saleId, () => []).add(SaleExtraCharge(
            id: r.id,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
            deletedAt: r.deletedAt,
            saleId: r.saleId,
            concept: r.concept,
            amount: Money(r.amountCents),
          ));
    }
    return [
      for (final h in headers)
        Sale(
          id: h.id,
          createdAt: h.createdAt,
          updatedAt: h.updatedAt,
          deletedAt: h.deletedAt,
          date: h.date,
          notes: h.notes,
          total: Money(h.totalCents),
          profit: Money(h.profitCents),
          lines: bySale[h.id] ?? const [],
          extraCharges: extrasBySale[h.id] ?? const [],
        ),
    ];
  }
}
