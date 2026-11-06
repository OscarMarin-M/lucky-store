import '../../core/errors/domain_exception.dart';
import '../../core/util/clock.dart';
import '../../core/util/current_user.dart';
import '../entities/purchase.dart';
import '../repositories/document_repositories.dart';

/// Voids a sale, purchase or write-off that was registered by mistake.
///
/// Documents are never erased: the voided one keeps its figures and shows
/// crossed out in the history, with who voided it and why. It stops counting
/// everywhere (reports, stock), and stock and average cost are replayed
/// without it, all in one transaction. Costs frozen in other sales and
/// write-offs are not touched, even if voiding a purchase moves the average.
class VoidDocument {
  VoidDocument({
    required PurchaseRepository purchases,
    required SaleRepository sales,
    required StockAdjustmentRepository adjustments,
    required TransactionRunner transactions,
    required InventoryReplayer inventory,
    Clock clock = DateTime.now,
    CurrentUser currentUser = noUser,
  }) : _purchases = purchases,
       _sales = sales,
       _adjustments = adjustments,
       _transactions = transactions,
       _inventory = inventory,
       _clock = clock,
       _currentUser = currentUser;

  final PurchaseRepository _purchases;
  final SaleRepository _sales;
  final StockAdjustmentRepository _adjustments;
  final TransactionRunner _transactions;
  final InventoryReplayer _inventory;
  final Clock _clock;
  final CurrentUser _currentUser;

  Future<void> sale(String id, {String? reason}) =>
      _void(_sales.markVoided, id, reason);

  Future<void> purchase(String id, {String? reason}) =>
      _void(_purchases.markVoided, id, reason);

  Future<void> writeOff(String id, {String? reason}) =>
      _void(_adjustments.markVoided, id, reason);

  Future<void> _void(
    Future<bool> Function(
      String id, {
      required DateTime at,
      String? by,
      String? reason,
    })
    mark,
    String id,
    String? reason,
  ) => _transactions.run(() async {
    final trimmed = reason?.trim();
    final marked = await mark(
      id,
      at: _clock(),
      by: _currentUser(),
      reason: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
    if (!marked) throw const AlreadyVoidedException();
    await _inventory.replay();
  });
}

/// Products that voiding [purchase] would leave below zero (its units were
/// already sold), with the stock they would end at. Voiding removes exactly
/// the units the purchase brought, so it is current stock minus those.
Map<String, int> negativeStockIfVoided(
  Purchase purchase,
  Map<String, int> stockByProduct,
) {
  final units = <String, int>{};
  for (final l in purchase.lines) {
    units.update(l.productId, (v) => v + l.unitsBase,
        ifAbsent: () => l.unitsBase);
  }
  return {
    for (final MapEntry(key: id, value: u) in units.entries)
      if ((stockByProduct[id] ?? 0) - u < 0) id: (stockByProduct[id] ?? 0) - u,
  };
}
