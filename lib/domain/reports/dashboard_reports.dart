import '../../core/money/money.dart';
import '../entities/product.dart';
import '../entities/purchase.dart';
import '../entities/sale.dart';
import '../entities/stock_adjustment.dart';
import '../repositories/document_repositories.dart';

/// Period shown in Inicio: `[from, to)`. Null bounds = since/until always.
class ReportPeriod {
  const ReportPeriod({this.from, this.to});

  factory ReportPeriod.today(DateTime now) {
    final start = DateTime(now.year, now.month, now.day);
    return ReportPeriod(from: start, to: start.add(const Duration(days: 1)));
  }

  /// Today and the 6 days before it.
  factory ReportPeriod.last7Days(DateTime now) {
    final end = DateTime(now.year, now.month, now.day + 1);
    return ReportPeriod(from: DateTime(now.year, now.month, now.day - 6), to: end);
  }

  factory ReportPeriod.thisMonth(DateTime now) => ReportPeriod(
    from: DateTime(now.year, now.month),
    to: DateTime(now.year, now.month + 1),
  );

  final DateTime? from;
  final DateTime? to;

  bool contains(DateTime d) =>
      (from == null || !d.isBefore(from!)) && (to == null || d.isBefore(to!));
}

/// Money of a period. Purchases are shown but do NOT reduce the profit: what
/// is bought is stock, and its cost is counted when it is sold or written off.
class PeriodSummary {
  const PeriodSummary({
    required this.salesTotal,
    required this.salesCount,
    required this.salesProfit,
    required this.purchasesTotal,
    required this.writeOffLoss,
    this.extraCharges = Money.zero,
  });

  factory PeriodSummary.of({
    required List<Sale> sales,
    required List<Purchase> purchases,
    required List<StockAdjustment> writeOffs,
  }) => PeriodSummary(
    salesTotal: sales.map((s) => s.total).sum,
    salesCount: sales.length,
    salesProfit: sales.map((s) => s.profit).sum,
    purchasesTotal: purchases.map((p) => p.total).sum,
    writeOffLoss: writeOffs.map((a) => a.costTotal).sum,
    extraCharges: sales.map((s) => s.extraChargesTotal).sum,
  );

  final Money salesTotal;
  final int salesCount;

  /// Includes each order's extra charges.
  final Money salesProfit;
  final Money purchasesTotal;
  final Money writeOffLoss;

  /// Extra charges of the orders (assembly, packaging...), shown apart
  /// because they belong to no product.
  final Money extraCharges;

  /// What the shop really earned: sales profit minus what was lost.
  Money get netProfit => salesProfit - writeOffLoss;
}

/// How much one product earned or lost in a period.
class ProductResult {
  const ProductResult({
    required this.productId,
    required this.name,
    required this.unitsSold,
    required this.revenue,
    required this.salesProfit,
    required this.writeOffLoss,
  });

  final String productId;
  final String name;
  final int unitsSold;
  final Money revenue;
  final Money salesProfit;
  final Money writeOffLoss;

  Money get netProfit => salesProfit - writeOffLoss;

  /// Net profit over revenue, in percent; null without sales.
  double? get marginPercent =>
      revenue.cents == 0 ? null : netProfit.cents * 100 / revenue.cents;
}

/// Sales profit per product (from the repository) minus each product's
/// write-off losses, best first. A product that only lost (expired, never
/// sold) shows up too: that is a loss the owner must see.
List<ProductResult> resultsByProduct({
  required List<ProductProfit> sales,
  required List<StockAdjustment> writeOffs,
  required Map<String, Product> productsById,
}) {
  final loss = <String, Money>{};
  for (final a in writeOffs) {
    loss[a.productId] = (loss[a.productId] ?? Money.zero) + a.costTotal;
  }
  final results = <ProductResult>[
    for (final s in sales)
      ProductResult(
        productId: s.productId,
        name: s.productName,
        unitsSold: s.unitsSold,
        revenue: s.revenue,
        salesProfit: s.profit,
        writeOffLoss: loss.remove(s.productId) ?? Money.zero,
      ),
    for (final MapEntry(key: id, value: lost) in loss.entries)
      ProductResult(
        productId: id,
        name: productsById[id]?.name ?? 'Producto eliminado',
        unitsSold: 0,
        revenue: Money.zero,
        salesProfit: Money.zero,
        writeOffLoss: lost,
      ),
  ];
  results.sort((a, b) {
    final byProfit = b.netProfit.compareTo(a.netProfit);
    return byProfit != 0 ? byProfit : a.name.compareTo(b.name);
  });
  return results;
}

/// What the stock on hand cost (average cost); negative stock counts as 0.
Money inventoryValue(Iterable<Product> products) => products
    .where((p) => p.stockUnits > 0)
    .map((p) => p.stockValue)
    .sum;

/// Active products at or under their minimum, emptiest first.
List<Product> lowStock(Iterable<Product> products) =>
    products.where((p) => p.isActive && p.isLowStock).toList()
      ..sort((a, b) {
        final byUnits = a.stockUnits.compareTo(b.stockUnits);
        return byUnits != 0 ? byUnits : a.name.compareTo(b.name);
      });

/// A lot that expires soon (or already did) and probably still has units.
class ExpiryAlert {
  const ExpiryAlert({
    required this.product,
    required this.expiry,
    required this.unitsLeft,
    required this.daysLeft,
  });

  final Product product;

  /// Earliest expiry of the lot (start of the range for loose units).
  final DateTime expiry;

  /// Estimate of the units of this lot still in stock (see [expiryAlerts]).
  final int unitsLeft;

  /// Negative = expired that many days ago.
  final int daysLeft;

  bool get isExpired => daysLeft < 0;
}

/// Lots expiring within [windowDays] of [today] that still have stock.
///
/// The average cost does not track units per lot, so the units left are
/// estimated assuming the oldest units sell first: the current stock is
/// assigned to the newest lots, and what does not fit is considered sold.
/// This keeps old, already sold lots from raising false alarms. Exact
/// figures per lot will come with FIFO costing.
List<ExpiryAlert> expiryAlerts({
  required List<Purchase> purchases,
  required Iterable<Product> products,
  required DateTime today,
  int windowDays = 30,
}) {
  final day = DateTime(today.year, today.month, today.day);
  final limit = day.add(Duration(days: windowDays));

  // Lines per product, newest purchase first.
  final sorted = [...purchases]..sort((a, b) => b.date.compareTo(a.date));
  final linesByProduct = <String, List<PurchaseLine>>{};
  for (final p in sorted) {
    for (final l in p.lines) {
      linesByProduct.putIfAbsent(l.productId, () => []).add(l);
    }
  }

  final alerts = <ExpiryAlert>[];
  for (final product in products) {
    if (!product.isActive) continue;
    var remaining = product.stockUnits;
    for (final lot in linesByProduct[product.id] ?? const <PurchaseLine>[]) {
      if (remaining <= 0) break;
      final left = lot.unitsBase < remaining ? lot.unitsBase : remaining;
      remaining -= left;
      final expiry = lot.expiryFrom;
      if (expiry == null || expiry.isAfter(limit)) continue;
      alerts.add(ExpiryAlert(
        product: product,
        expiry: expiry,
        unitsLeft: left,
        daysLeft: DateTime(expiry.year, expiry.month, expiry.day)
            .difference(day)
            .inDays,
      ));
    }
  }
  alerts.sort((a, b) => a.expiry.compareTo(b.expiry));
  return alerts;
}
