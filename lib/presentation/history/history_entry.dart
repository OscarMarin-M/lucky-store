import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/money/money.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/stock_adjustment.dart';

/// Which documents the history shows.
enum HistoryFilter { all, sales, purchases, writeOffs }

/// One row of the history: a sale, a purchase or a write-off. They live in
/// different tables but the owner reads them as one timeline.
sealed class HistoryEntry {
  const HistoryEntry();

  DateTime get date;
  String get id;

  /// Money that moved: sale total, purchase total or write-off loss.
  Money get amount;

  bool matches(HistoryFilter f);

  /// Shown crossed out and left out of the day totals.
  bool get isVoided;
}

final class SaleEntry extends HistoryEntry {
  const SaleEntry(this.sale);
  final Sale sale;

  @override
  DateTime get date => sale.date;
  @override
  String get id => sale.id;
  @override
  Money get amount => sale.total;
  @override
  bool get isVoided => sale.isVoided;
  @override
  bool matches(HistoryFilter f) =>
      f == HistoryFilter.all || f == HistoryFilter.sales;
}

final class PurchaseEntry extends HistoryEntry {
  const PurchaseEntry(this.purchase);
  final Purchase purchase;

  @override
  DateTime get date => purchase.date;
  @override
  String get id => purchase.id;
  @override
  Money get amount => purchase.total;
  @override
  bool get isVoided => purchase.isVoided;
  @override
  bool matches(HistoryFilter f) =>
      f == HistoryFilter.all || f == HistoryFilter.purchases;

  /// Earliest recorded expiry among the lots, to flag it in the list.
  DateTime? get firstExpiry {
    DateTime? first;
    for (final l in purchase.lines) {
      final d = l.expiryFrom;
      if (d != null && (first == null || d.isBefore(first))) first = d;
    }
    return first;
  }
}

final class WriteOffEntry extends HistoryEntry {
  const WriteOffEntry(this.adjustment);
  final StockAdjustment adjustment;

  @override
  DateTime get date => adjustment.date;
  @override
  String get id => adjustment.id;
  @override
  Money get amount => adjustment.costTotal;
  @override
  bool get isVoided => adjustment.isVoided;
  @override
  bool matches(HistoryFilter f) =>
      f == HistoryFilter.all || f == HistoryFilter.writeOffs;
}

/// All documents as one timeline, newest first. Same instant: the id breaks
/// the tie so the order never jumps between rebuilds.
List<HistoryEntry> mergeHistory({
  required List<Purchase> purchases,
  required List<Sale> sales,
  required List<StockAdjustment> writeOffs,
}) {
  final all = <HistoryEntry>[
    ...sales.map(SaleEntry.new),
    ...purchases.map(PurchaseEntry.new),
    ...writeOffs.map(WriteOffEntry.new),
  ];
  all.sort((a, b) {
    final byDate = b.date.compareTo(a.date);
    return byDate != 0 ? byDate : b.id.compareTo(a.id);
  });
  return all;
}

/// Entries of one calendar day, with what was sold and earned that day.
class HistoryDay {
  HistoryDay(this.day, this.entries);

  final DateTime day;
  final List<HistoryEntry> entries;

  /// Voided documents are listed but count for nothing.
  Iterable<HistoryEntry> get _counted => entries.where((e) => !e.isVoided);

  /// Whether the day has sales that count (to show its totals).
  bool get hasSales => _counted.any((e) => e is SaleEntry);

  Money get salesTotal =>
      _counted.whereType<SaleEntry>().map((e) => e.sale.total).sum;

  /// Sales profit minus write-off losses of the day.
  Money get profit =>
      _counted.whereType<SaleEntry>().map((e) => e.sale.profit).sum -
      _counted
          .whereType<WriteOffEntry>()
          .map((e) => e.adjustment.costTotal)
          .sum;
}

/// Groups an already sorted (newest first) timeline by calendar day.
List<HistoryDay> groupByDay(List<HistoryEntry> entries) {
  final days = <HistoryDay>[];
  for (final e in entries) {
    final day = DateTime(e.date.year, e.date.month, e.date.day);
    if (days.isEmpty || days.last.day != day) {
      days.add(HistoryDay(day, []));
    }
    days.last.entries.add(e);
  }
  return days;
}

// The history also lists voided documents (crossed out); the reports read
// the providers of `providers.dart`, which leave them out.
final _purchasesWithVoided = StreamProvider<List<Purchase>>(
  (ref) => ref.watch(purchaseRepositoryProvider).watchAll(includeVoided: true),
);
final _salesWithVoided = StreamProvider<List<Sale>>(
  (ref) => ref.watch(saleRepositoryProvider).watchAll(includeVoided: true),
);
final _writeOffsWithVoided = StreamProvider<List<StockAdjustment>>(
  (ref) => ref
      .watch(stockAdjustmentRepositoryProvider)
      .watchAll(includeVoided: true),
);

/// The timeline, refreshed whenever a purchase, sale or write-off is saved
/// or voided.
final historyProvider = FutureProvider<List<HistoryEntry>>((ref) async {
  final purchases = await ref.watch(_purchasesWithVoided.future);
  final sales = await ref.watch(_salesWithVoided.future);
  final writeOffs = await ref.watch(_writeOffsWithVoided.future);
  return mergeHistory(
    purchases: purchases,
    sales: sales,
    writeOffs: writeOffs,
  );
});
