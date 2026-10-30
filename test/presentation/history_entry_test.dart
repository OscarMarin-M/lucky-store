import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/domain/entities/purchase.dart';
import 'package:lucky_store/domain/entities/sale.dart';
import 'package:lucky_store/domain/entities/stock_adjustment.dart';
import 'package:lucky_store/presentation/format/date_format.dart';
import 'package:lucky_store/presentation/format/stock_format.dart';
import 'package:lucky_store/presentation/history/history_entry.dart';

Sale _sale(String id, DateTime date, {int total = 1000, int profit = 300}) =>
    Sale(
      id: id,
      createdAt: date,
      updatedAt: date,
      date: date,
      total: Money(total),
      profit: Money(profit),
      lines: const [],
    );

Purchase _purchase(String id, DateTime date, {List<PurchaseLine> lines = const []}) =>
    Purchase(
      id: id,
      createdAt: date,
      updatedAt: date,
      date: date,
      total: const Money(4800),
      lines: lines,
    );

StockAdjustment _writeOff(String id, DateTime date, {int loss = 200}) =>
    StockAdjustment(
      id: id,
      createdAt: date,
      updatedAt: date,
      productId: 'p',
      date: date,
      quantity: 1,
      presentation: Presentation.unit,
      unitsBase: 1,
      reason: AdjustmentReason.expired,
      unitCost: UnitCost(loss * 100),
      costTotal: Money(loss),
    );

PurchaseLine _lot(String id, {DateTime? from, DateTime? to}) => PurchaseLine(
      id: id,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      purchaseId: 'c',
      productId: 'p',
      quantity: 1,
      presentation: Presentation.box,
      unitsBase: 24,
      lineTotal: const Money(4800),
      unitCost: const UnitCost(20000),
      expiryFrom: from,
      expiryTo: to,
    );

void main() {
  test('one timeline, newest first, mixing the three kinds', () {
    final entries = mergeHistory(
      purchases: [_purchase('c1', DateTime(2026, 10, 28, 9))],
      sales: [
        _sale('v1', DateTime(2026, 10, 29, 10)),
        _sale('v2', DateTime(2026, 10, 27, 18)),
      ],
      writeOffs: [_writeOff('b1', DateTime(2026, 10, 29, 8))],
    );
    expect(entries.map((e) => e.id), ['v1', 'b1', 'c1', 'v2']);
  });

  test('filters keep only their kind', () {
    final entries = mergeHistory(
      purchases: [_purchase('c1', DateTime(2026, 10, 28))],
      sales: [_sale('v1', DateTime(2026, 10, 29))],
      writeOffs: [_writeOff('b1', DateTime(2026, 10, 27))],
    );
    String only(HistoryFilter f) =>
        entries.where((e) => e.matches(f)).map((e) => e.id).join(',');
    expect(only(HistoryFilter.all), 'v1,c1,b1');
    expect(only(HistoryFilter.sales), 'v1');
    expect(only(HistoryFilter.purchases), 'c1');
    expect(only(HistoryFilter.writeOffs), 'b1');
  });

  test('days group entries; profit of a day subtracts write-off losses', () {
    final days = groupByDay(mergeHistory(
      purchases: [_purchase('c1', DateTime(2026, 10, 29, 7))],
      sales: [
        _sale('v1', DateTime(2026, 10, 29, 20), total: 1000, profit: 300),
        _sale('v2', DateTime(2026, 10, 29, 9), total: 500, profit: -50),
        _sale('v3', DateTime(2026, 10, 28, 12)),
      ],
      writeOffs: [_writeOff('b1', DateTime(2026, 10, 29, 8), loss: 200)],
    ));

    expect(days, hasLength(2));
    expect(days[0].day, DateTime(2026, 10, 29));
    expect(days[0].entries.map((e) => e.id), ['v1', 'v2', 'b1', 'c1']);
    expect(days[0].salesTotal, const Money(1500));
    // 300 - 50 - 200; purchases are stock, not a loss
    expect(days[0].profit, const Money(50));
    expect(days[1].entries.single.id, 'v3');
  });

  test('a purchase flags its earliest expiry', () {
    final p = PurchaseEntry(_purchase('c', DateTime(2026, 10, 29), lines: [
      _lot('a', from: DateTime(2027, 5, 1), to: DateTime(2027, 5, 1)),
      _lot('b'),
      _lot('c', from: DateTime(2027, 2, 1), to: DateTime(2027, 3, 1)),
    ]));
    expect(p.firstExpiry, DateTime(2027, 2, 1));
    expect(PurchaseEntry(_purchase('d', DateTime(2026))).firstExpiry, isNull);
  });

  test('day labels and line quantities', () {
    final now = DateTime(2026, 10, 29, 15);
    expect(formatDayLabel(DateTime(2026, 10, 29, 1), now), 'Hoy');
    expect(formatDayLabel(DateTime(2026, 10, 28, 23), now), 'Ayer');
    expect(formatDayLabel(DateTime(2026, 10, 26), now), 'lun 26/10/2026');
    expect(formatTime(DateTime(2026, 1, 1, 9, 5)), '09:05');

    expect(
      formatLineQuantity(quantity: 2, isBox: true, unitsBase: 72, unitsPerBox: 36),
      '2 cajas de 36 u',
    );
    expect(formatLineQuantity(quantity: 1, isBox: true, unitsBase: 24), '1 caja de 24 u');
    expect(formatLineQuantity(quantity: 10, isBox: false, unitsBase: 10), '10 u');
  });
}
