import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/money/money.dart';
import '../../domain/entities/product.dart';
import '../../domain/reports/dashboard_reports.dart';

/// Periods offered in Inicio.
enum HomePeriod { today, week, month, all }

ReportPeriod reportPeriodFor(HomePeriod p, DateTime now) => switch (p) {
  HomePeriod.today => ReportPeriod.today(now),
  HomePeriod.week => ReportPeriod.last7Days(now),
  HomePeriod.month => ReportPeriod.thisMonth(now),
  HomePeriod.all => const ReportPeriod(),
};

/// Everything Inicio shows. Money figures follow the chosen period; stock,
/// inventory value and alerts are always "right now".
class Dashboard {
  const Dashboard({
    required this.summary,
    required this.results,
    required this.inventoryValue,
    required this.productsInStock,
    required this.lowStock,
    required this.expiring,
  });

  final PeriodSummary summary;
  final List<ProductResult> results;
  final Money inventoryValue;
  final int productsInStock;
  final List<Product> lowStock;
  final List<ExpiryAlert> expiring;

  bool get hasAlerts => lowStock.isNotEmpty || expiring.isNotEmpty;
}

/// Recomputed whenever a product, purchase, sale or write-off changes.
final dashboardProvider =
    FutureProvider.family<Dashboard, HomePeriod>((ref, period) async {
  final products = await ref.watch(productsProvider.future);
  final byId = await ref.watch(productsByIdProvider.future);
  final purchases = await ref.watch(purchasesProvider.future);
  final sales = await ref.watch(salesProvider.future);
  final writeOffs = await ref.watch(stockAdjustmentsProvider.future);

  final now = DateTime.now();
  final range = reportPeriodFor(period, now);
  final periodWriteOffs =
      writeOffs.where((a) => range.contains(a.date)).toList();
  final profit = await ref
      .watch(saleRepositoryProvider)
      .profitByProduct(from: range.from, to: range.to);

  return Dashboard(
    summary: PeriodSummary.of(
      sales: sales.where((s) => range.contains(s.date)).toList(),
      purchases: purchases.where((p) => range.contains(p.date)).toList(),
      writeOffs: periodWriteOffs,
    ),
    results: resultsByProduct(
      sales: profit,
      writeOffs: periodWriteOffs,
      productsById: byId,
    ),
    inventoryValue: inventoryValue(products),
    productsInStock: products.where((p) => p.stockUnits > 0).length,
    lowStock: lowStock(products),
    expiring: expiryAlerts(purchases: purchases, products: products, today: now),
  );
});
