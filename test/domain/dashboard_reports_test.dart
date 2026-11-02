import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/domain/entities/purchase.dart';
import 'package:lucky_store/domain/entities/sale.dart';
import 'package:lucky_store/domain/entities/stock_adjustment.dart';
import 'package:lucky_store/domain/reports/dashboard_reports.dart';
import 'package:lucky_store/domain/repositories/document_repositories.dart';

final _t = DateTime(2026, 10, 1);

Product _product(
  String id, {
  int stock = 0,
  int cost = 20000,
  int? min,
  bool active = true,
}) => Product(
  id: id,
  createdAt: _t,
  updatedAt: _t,
  name: id,
  stockUnits: stock,
  avgCost: UnitCost(cost),
  minStockUnits: min,
  isActive: active,
);

Sale _sale(int total, int profit) => Sale(
  id: 's$total',
  createdAt: _t,
  updatedAt: _t,
  date: _t,
  total: Money(total),
  profit: Money(profit),
  lines: const [],
);

StockAdjustment _writeOff(String productId, int loss) => StockAdjustment(
  id: 'a$productId$loss',
  createdAt: _t,
  updatedAt: _t,
  productId: productId,
  date: _t,
  quantity: 1,
  presentation: Presentation.unit,
  unitsBase: 1,
  reason: AdjustmentReason.expired,
  unitCost: UnitCost(loss * 100),
  costTotal: Money(loss),
);

/// A purchase on [date] with one lot of [units] for [productId].
Purchase _buy(String productId, DateTime date, int units, {DateTime? expiry}) =>
    Purchase(
      id: 'p$productId${date.toIso8601String()}',
      createdAt: date,
      updatedAt: date,
      date: date,
      total: Money(units * 200),
      lines: [
        PurchaseLine(
          id: 'l$productId${date.toIso8601String()}',
          createdAt: date,
          updatedAt: date,
          purchaseId: 'p',
          productId: productId,
          quantity: units,
          presentation: Presentation.unit,
          unitsBase: units,
          lineTotal: Money(units * 200),
          unitCost: const UnitCost(20000),
          expiryFrom: expiry,
          expiryTo: expiry,
        ),
      ],
    );

void main() {
  group('ReportPeriod', () {
    final now = DateTime(2026, 10, 29, 15, 30);

    test('today, last 7 days and this month are [from, to)', () {
      final today = ReportPeriod.today(now);
      expect(today.from, DateTime(2026, 10, 29));
      expect(today.to, DateTime(2026, 10, 30));

      final week = ReportPeriod.last7Days(now);
      expect(week.from, DateTime(2026, 10, 23));
      expect(week.to, DateTime(2026, 10, 30));

      final month = ReportPeriod.thisMonth(DateTime(2026, 12, 5));
      expect(month.from, DateTime(2026, 12));
      expect(month.to, DateTime(2027, 1));
      expect(month.contains(DateTime(2026, 12, 31, 23, 59)), isTrue);
      expect(month.contains(DateTime(2027, 1, 1)), isFalse);
      expect(const ReportPeriod().contains(DateTime(1999)), isTrue);
    });
  });

  test('summary: purchases are shown but only write-offs reduce profit', () {
    final s = PeriodSummary.of(
      sales: [_sale(3000, 1000), _sale(1500, -100)],
      purchases: [_buy('a', _t, 24)],
      writeOffs: [_writeOff('a', 200)],
    );
    expect(s.salesTotal, const Money(4500));
    expect(s.salesCount, 2);
    expect(s.salesProfit, const Money(900));
    expect(s.purchasesTotal, const Money(4800));
    expect(s.writeOffLoss, const Money(200));
    expect(s.netProfit, const Money(700));
    expect(s.extraCharges, Money.zero);
  });

  test('summary: extra charges are already inside sales total and profit', () {
    final now = DateTime(2026, 10, 29);
    final order = Sale(
      id: 'o',
      createdAt: now,
      updatedAt: now,
      date: now,
      total: const Money(6650), // products 6000 + charges 650
      profit: const Money(3650), // products 3000 + charges 650
      lines: const [],
      extraCharges: [
        SaleExtraCharge(
          id: 'e1',
          createdAt: now,
          updatedAt: now,
          saleId: 'o',
          concept: 'Mano de obra',
          amount: const Money(500),
        ),
        SaleExtraCharge(
          id: 'e2',
          createdAt: now,
          updatedAt: now,
          saleId: 'o',
          concept: 'Cinta',
          amount: const Money(150),
        ),
      ],
    );
    final s = PeriodSummary.of(sales: [order], purchases: [], writeOffs: []);
    expect(s.extraCharges, const Money(650));
    expect(s.salesTotal, const Money(6650));
    expect(s.netProfit, const Money(3650), reason: 'not added twice');
  });

  test(
    'results per product subtract write-offs; loss-only products appear',
    () {
      final results = resultsByProduct(
        sales: const [
          ProductProfit(
            productId: 'snickers',
            productName: 'Snickers',
            unitsSold: 10,
            revenue: Money(3000),
            cost: Money(2000),
            profit: Money(1000),
          ),
          ProductProfit(
            productId: 'twix',
            productName: 'Twix',
            unitsSold: 5,
            revenue: Money(1500),
            cost: Money(1000),
            profit: Money(500),
          ),
        ],
        writeOffs: [
          _writeOff('snickers', 800),
          _writeOff('gum', 300),
          _writeOff('gum', 100),
        ],
        productsById: {'gum': _product('gum').copyWith(name: 'Chicle')},
      );

      expect(results.map((r) => r.name), ['Twix', 'Snickers', 'Chicle']);
      expect(results[1].netProfit, const Money(200)); // 1000 - 800
      expect(results[1].marginPercent, closeTo(6.67, 0.01));
      expect(results[2].netProfit, const Money(-400));
      expect(results[2].unitsSold, 0);
      expect(results[2].marginPercent, isNull);
    },
  );

  test('inventory value ignores negative stock', () {
    expect(
      inventoryValue([
        _product('a', stock: 10, cost: 20000), // Bs 20
        _product('b', stock: 3, cost: 15000), // Bs 4,50
        _product('c', stock: -2, cost: 20000),
      ]),
      const Money(2450),
    );
  });

  test('low stock: only active products with a minimum, emptiest first', () {
    final low = lowStock([
      _product('a', stock: 5, min: 6),
      _product('b', stock: 0, min: 1),
      _product('c', stock: 6, min: 6), // at the minimum counts
      _product('d', stock: 7, min: 6),
      _product('e', stock: 0), // no minimum set
      _product('f', stock: 0, min: 5, active: false),
    ]);
    expect(low.map((p) => p.id), ['b', 'a', 'c']);
  });

  group('expiry alerts', () {
    final today = DateTime(2026, 10, 29, 18);

    test('soon and already expired lots with stock, soonest first', () {
      final alerts = expiryAlerts(
        purchases: [
          _buy('a', DateTime(2026, 10, 1), 24, expiry: DateTime(2026, 11, 10)),
          _buy('b', DateTime(2026, 10, 2), 10, expiry: DateTime(2026, 10, 27)),
          _buy('c', DateTime(2026, 10, 3), 10, expiry: DateTime(2027, 6, 1)),
          _buy('d', DateTime(2026, 10, 4), 10), // no date recorded
        ],
        products: [
          _product('a', stock: 30),
          _product('b', stock: 4),
          _product('c', stock: 10),
          _product('d', stock: 10),
        ],
        today: today,
      );
      expect(alerts.map((a) => a.product.id), ['b', 'a']);
      expect(alerts[0].isExpired, isTrue);
      expect(alerts[0].daysLeft, -2);
      expect(alerts[0].unitsLeft, 4);
      expect(alerts[1].daysLeft, 12);
      expect(alerts[1].unitsLeft, 24, reason: 'capped at the lot size');
    });

    test('an old lot already covered by newer purchases does not alert', () {
      // 24 bought long ago (expires soon), then 24 more: stock 20 fits in
      // the newest lot, so the old one is assumed sold.
      final alerts = expiryAlerts(
        purchases: [
          _buy('a', DateTime(2026, 6, 1), 24, expiry: DateTime(2026, 11, 1)),
          _buy('a', DateTime(2026, 10, 20), 24, expiry: DateTime(2027, 4, 1)),
        ],
        products: [_product('a', stock: 20)],
        today: today,
      );
      expect(alerts, isEmpty);

      // With 30 in stock, 6 must still come from the old lot.
      final more = expiryAlerts(
        purchases: [
          _buy('a', DateTime(2026, 6, 1), 24, expiry: DateTime(2026, 11, 1)),
          _buy('a', DateTime(2026, 10, 20), 24, expiry: DateTime(2027, 4, 1)),
        ],
        products: [_product('a', stock: 30)],
        today: today,
      );
      expect(more.single.unitsLeft, 6);
    });

    test('no stock or inactive product: no alert', () {
      final alerts = expiryAlerts(
        purchases: [
          _buy('a', _t, 10, expiry: DateTime(2026, 11, 1)),
          _buy('b', _t, 10, expiry: DateTime(2026, 11, 1)),
        ],
        products: [_product('a'), _product('b', stock: 5, active: false)],
        today: today,
      );
      expect(alerts, isEmpty);
    });
  });

  group('top sellers', () {
    ProductProfit sold(String id, int units, {int revenue = 0}) =>
        ProductProfit(
          productId: id,
          productName: id,
          unitsSold: units,
          revenue: Money(revenue),
          cost: Money.zero,
          profit: Money.zero,
        );

    test('elapsed days count today and stop at the period end', () {
      final now = DateTime(2026, 11, 3, 15);
      expect(elapsedDays(ReportPeriod.today(now), now), 1);
      expect(elapsedDays(ReportPeriod.last7Days(now), now), 7);
      // "Este mes" on the 3rd: 3 days lived, not 30.
      expect(elapsedDays(ReportPeriod.thisMonth(now), now), 3);
      // "Todo": since the first sale.
      expect(
        elapsedDays(
          const ReportPeriod(),
          now,
          firstSale: DateTime(2026, 10, 25, 18),
        ),
        10,
      );
      expect(elapsedDays(const ReportPeriod(), now), 1);
    });

    test('ranks by units sold, ties by revenue, and limits the list', () {
      final byId = {
        for (final id in ['a', 'b', 'c', 'd']) id: _product(id, stock: 100),
      };
      final top = topSellers(
        sales: [
          sold('a', 5, revenue: 100),
          sold('b', 20),
          sold('c', 5, revenue: 300),
          sold('d', 1),
        ],
        productsById: byId,
        periodDays: 1,
        limit: 3,
      );
      expect(top.map((t) => t.product.id), ['b', 'c', 'a']);
    });

    test('days of stock follow the pace; restock under a week', () {
      final top = topSellers(
        sales: [sold('fast', 70), sold('slow', 7), sold('empty', 3)],
        productsById: {
          'fast': _product('fast', stock: 30), // 10 u/día -> 3 días
          'slow': _product('slow', stock: 30), // 1 u/día -> 30 días
          'empty': _product('empty'),
        },
        periodDays: 7,
      );
      final byId = {for (final t in top) t.product.id: t};
      expect(byId['fast']!.unitsPerDay, 10);
      expect(byId['fast']!.daysOfStock, 3);
      expect(byId['fast']!.needsRestock, isTrue);
      expect(byId['slow']!.daysOfStock, 30);
      expect(byId['slow']!.needsRestock, isFalse);
      expect(byId['empty']!.daysOfStock, 0);
      expect(byId['empty']!.needsRestock, isTrue);
    });

    test('a product under its minimum needs restock even if it lasts', () {
      final top = topSellers(
        sales: [sold('a', 1)],
        productsById: {'a': _product('a', stock: 10, min: 10)},
        periodDays: 30,
      );
      expect(top.single.needsRestock, isTrue);
    });

    test('skips deleted products', () {
      final top = topSellers(
        sales: [sold('gone', 9)],
        productsById: {
          'gone': _product('gone').copyWith(deletedAt: DateTime(2026, 10, 2)),
        },
        periodDays: 1,
      );
      expect(top, isEmpty);
    });
  });
}
