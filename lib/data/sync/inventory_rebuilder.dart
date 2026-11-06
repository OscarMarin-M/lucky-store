import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../domain/costing/cost_strategy.dart';
import '../../domain/repositories/document_repositories.dart';
import '../database/app_database.dart';

/// Recomputes stock and average cost of every product from the documents of
/// all phones, replaying purchases, sales and write-offs in date order.
///
/// Every phone replays the same documents in the same order, so they all
/// reach the same numbers no matter who synced first. Costs already frozen
/// in sales and write-offs are not touched: history never moves.
class InventoryRebuilder implements InventoryReplayer {
  InventoryRebuilder(this._db, this._strategy);

  final AppDatabase _db;
  final CostStrategy _strategy;

  @override
  Future<void> replay() => rebuild();

  /// Returns how many products changed.
  Future<int> rebuild() async {
    final events = await _db
        .customSelect(
          // Ties on the date are broken by when the document was created and
          // then by id, so the order is the same on every phone.
          'SELECT pl.product_id, p.date, p.created_at, pl.id, 1 AS inflow, '
          '  pl.units_base, pl.line_total_cents AS total_cents '
          'FROM purchase_lines pl JOIN purchases p ON p.id = pl.purchase_id '
          'WHERE pl.deleted_at IS NULL AND p.deleted_at IS NULL '
          'UNION ALL '
          'SELECT sl.product_id, s.date, s.created_at, sl.id, 0, sl.units_base, 0 '
          'FROM sale_lines sl JOIN sales s ON s.id = sl.sale_id '
          'WHERE sl.deleted_at IS NULL AND s.deleted_at IS NULL '
          'UNION ALL '
          'SELECT product_id, date, created_at, id, 0, units_base, 0 '
          'FROM stock_adjustments WHERE deleted_at IS NULL',
          readsFrom: {
            _db.purchases,
            _db.purchaseLines,
            _db.sales,
            _db.saleLines,
            _db.stockAdjustments,
          },
        )
        .get();

    // Dates are compared as instants, not as text: rows downloaded from the
    // cloud and rows written here may carry different offsets.
    final sorted =
        [
          for (final r in events)
            (
              productId: r.read<String>('product_id'),
              date: DateTime.parse(r.read<String>('date')),
              createdAt: DateTime.parse(r.read<String>('created_at')),
              id: r.read<String>('id'),
              inflow: r.read<int>('inflow') == 1,
              units: r.read<int>('units_base'),
              total: Money(r.read<int>('total_cents')),
            ),
        ]..sort((a, b) {
          final byDate = a.date.compareTo(b.date);
          if (byDate != 0) return byDate;
          final byCreated = a.createdAt.compareTo(b.createdAt);
          return byCreated != 0 ? byCreated : a.id.compareTo(b.id);
        });

    final states = <String, StockState>{};
    for (final e in sorted) {
      if (e.units <= 0) continue;
      final state = states[e.productId] ?? StockState.empty;
      states[e.productId] = e.inflow
          ? _strategy.applyPurchase(state, units: e.units, total: e.total)
          // What already happened is replayed as it was, even if two phones
          // sold the last unit at the same time (stock goes negative).
          : _strategy
                .applyOutflow(state, units: e.units, allowNegativeStock: true)
                .newState;
    }

    var changed = 0;
    for (final p in await _db.select(_db.products).get()) {
      final s = states[p.id] ?? StockState.empty;
      if (s.units == p.stockUnits && s.avgCost == UnitCost(p.avgCostRaw)) {
        continue;
      }
      // Only stock columns: the outbox triggers ignore them, so a rebuild
      // is never uploaded back.
      await (_db.update(_db.products)..where((t) => t.id.equals(p.id))).write(
        ProductsCompanion(
          stockUnits: Value(s.units),
          avgCostRaw: Value(s.avgCost.raw),
        ),
      );
      changed++;
    }
    return changed;
  }
}
