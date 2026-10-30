import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/domain/entities/stock_adjustment.dart';
import 'package:lucky_store/domain/purchasing/purchase_lot.dart';
import 'package:lucky_store/domain/usecases/inventory_ledger.dart';
import 'package:lucky_store/domain/usecases/register_purchase.dart';
import 'package:lucky_store/domain/usecases/register_sale.dart';

import 'test_env.dart';

void main() {
  late TestEnv env;

  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  /// Box of 24, suggested Bs 3,00 per unit / Bs 65,00 per box.
  Future<Product> newCandy([String name = 'Snickers']) =>
      env.products.create(Product.create(
        name: name,
        unitsPerBox: 24,
        suggestedPriceUnit: const Money(300),
        suggestedPriceBox: const Money(6500),
      ));

  /// Lot of [qty] boxes (product's box size) or units costing [total] in all.
  PurchaseLot lotOf(Product p, int qty, Presentation pres, Money total) =>
      switch (pres) {
        Presentation.box => BoxLot(
            boxes: qty,
            unitsPerBox: p.unitsPerBox,
            pricePerBox: Money(total.cents ~/ qty),
          ),
        Presentation.unit =>
          LooseUnitsLot(units: qty, unitPrice: Money(total.cents ~/ qty)),
      };

  Future<void> buy(
    Product p,
    int qty,
    Presentation pres,
    String total, {
    DateTime? date,
  }) =>
      env.registerPurchase(
        date: date,
        lines: [
          PurchaseLineInput(
            productId: p.id,
            lot: lotOf(p, qty, pres, Money.parse(total)),
          ),
        ],
      );

  Future<Product> reload(Product p) async => (await env.products.getById(p.id))!;

  group('purchases', () {
    test('boxes are converted to base units and the cost is stored', () async {
      final p = await newCandy();
      await buy(p, 2, Presentation.box, '96');

      final after = await reload(p);
      expect(after.stockUnits, 48);
      expect(after.avgCost.raw, 20000); // Bs 2,00 per unit

      final purchase = (await env.purchases.getAll()).single;
      expect(purchase.total, const Money(9600));
      final line = purchase.lines.single;
      expect(line.quantity, 2);
      expect(line.presentation, Presentation.box);
      expect(line.unitsBase, 48);
      expect(line.unitCost.raw, 20000);
    });

    test('second purchase at another price gives the weighted average', () async {
      final p = await newCandy();
      await buy(p, 2, Presentation.box, '96'); // 48 @ 2,00
      await buy(p, 1, Presentation.box, '72'); // 24 @ 3,00

      final after = await reload(p);
      expect(after.stockUnits, 72);
      // (48*2 + 24*3) / 72 = 2,3333
      expect(after.avgCost.raw, 23333);
    });

    test('mixing units and boxes in one purchase', () async {
      final p = await newCandy();
      await env.registerPurchase(lines: [
        PurchaseLineInput(
          productId: p.id,
          lot: BoxLot(boxes: 1, unitsPerBox: 24, pricePerBox: const Money(4800)),
        ),
        PurchaseLineInput(
          productId: p.id,
          lot: LooseUnitsLot(units: 6, unitPrice: const Money(300)),
        ),
      ]);
      final after = await reload(p);
      expect(after.stockUnits, 30);
      // (24*2 + 6*3) / 30 = 2,20
      expect(after.avgCost.raw, 22000);
    });

    test('a lot keeps its own box size, expiry and code', () async {
      final p = await newCandy(); // product default: box of 24
      await env.registerPurchase(lines: [
        PurchaseLineInput(
          productId: p.id,
          lot: BoxLot(
            boxes: 1,
            unitsPerBox: 36, // this supplier brings boxes of 36
            pricePerBox: Money.parse('72'),
            expiry: DateTime(2027, 3, 15),
            lotCode: 'L-2291',
          ),
        ),
        PurchaseLineInput(
          productId: p.id,
          lot: LooseUnitsLot(
            units: 12,
            unitPrice: Money.parse('1,50'),
            expiryFrom: DateTime(2027, 1, 10),
            expiryTo: DateTime(2027, 2, 20),
          ),
        ),
      ]);

      final after = await reload(p);
      expect(after.stockUnits, 48);
      expect(after.unitsPerBox, 24, reason: 'product default untouched');
      // (36*2,00 + 12*1,50) / 48 = 1,875
      expect(after.avgCost.raw, 18750);

      final lines = (await env.purchases.getAll()).single.lines;
      expect(lines[0].unitsPerBox, 36);
      expect(lines[0].unitsBase, 36);
      expect(lines[0].expiryFrom, DateTime(2027, 3, 15));
      expect(lines[0].expiryTo, DateTime(2027, 3, 15));
      expect(lines[0].lotCode, 'L-2291');
      expect(lines[1].unitsPerBox, isNull);
      expect(lines[1].expiryFrom, DateTime(2027, 1, 10));
      expect(lines[1].expiryTo, DateTime(2027, 2, 20));
      expect(lines[1].unitCost.raw, 15000);
    });

    test('unknown product and empty purchases are rejected', () async {
      expect(
        () => env.registerPurchase(lines: [
          PurchaseLineInput(
            productId: 'nope',
            lot: LooseUnitsLot(units: 1, unitPrice: const Money(100)),
          ),
        ]),
        throwsA(isA<EntityNotFoundException>()),
      );
      expect(() => env.registerPurchase(lines: []),
          throwsA(isA<EmptyDocumentException>()));
    });
  });

  group('sales', () {
    late Product p;

    setUp(() async {
      p = await newCandy();
      await buy(p, 2, Presentation.box, '96');
      await buy(p, 1, Presentation.box, '72'); // 72 units @ 2,3333
    });

    test('profit = (price - average cost) x quantity, stock goes down', () async {
      final sale = await env.registerSale(lines: [
        SaleLineInput(
          productId: p.id,
          quantity: 10,
          presentation: Presentation.unit,
        ),
      ]);

      final line = sale.lines.single;
      expect(line.unitsBase, 10);
      expect(line.unitPrice, const Money(300)); // suggested price used
      expect(line.lineTotal, const Money(3000));
      expect(line.costAtSale.raw, 23333);
      expect(line.costTotal, const Money(2333)); // 10 x 2,3333 -> 23,33
      expect(line.profit, const Money(667));
      expect(sale.total, const Money(3000));
      expect(sale.profit, const Money(667));

      final after = await reload(p);
      expect(after.stockUnits, 62);
      expect(after.avgCost.raw, 23333, reason: 'selling must not change the average');
    });

    test('an order with extra charges: the customer pays them, all profit',
        () async {
      // Promo box: 30 candies at Bs 5,00 plus assembly and printing charged
      // on top.
      final sale = await env.registerSale(
        notes: 'Caja San Valentín',
        lines: [
          SaleLineInput(
            productId: p.id,
            quantity: 30,
            presentation: Presentation.unit,
            unitPrice: const Money(500),
          ),
        ],
        extraCharges: [
          ExtraChargeInput(concept: ' Mano de obra ', amount: Money.parse('10')),
          ExtraChargeInput(concept: 'Impresión', amount: Money.parse('4,50')),
        ],
      );

      // 30 x 5,00 = 150; cost 30 x 2,3333 = 70,00; lines profit 80,00
      expect(sale.linesTotal, const Money(15000));
      expect(sale.extraChargesTotal, const Money(1450));
      expect(sale.total, const Money(16450));
      expect(sale.linesProfit, const Money(8000));
      expect(sale.profit, const Money(9450));

      final stored = (await env.sales.getById(sale.id))!;
      expect(stored.notes, 'Caja San Valentín');
      expect(stored.total, const Money(16450));
      expect(stored.profit, const Money(9450));
      expect(stored.extraCharges.map((c) => c.concept), ['Mano de obra', 'Impresión']);
      expect(stored.extraCharges.map((c) => c.amount.cents), [1000, 450]);
      expect((await reload(p)).stockUnits, 42, reason: 'extras are not stock');
    });

    test('extra charges need a concept and an amount above 0', () async {
      Future<void> sell(ExtraChargeInput c) => env.registerSale(
            lines: [
              SaleLineInput(
                productId: p.id,
                quantity: 1,
                presentation: Presentation.unit,
              ),
            ],
            extraCharges: [c],
          );
      expect(() => sell(ExtraChargeInput(concept: ' ', amount: Money.parse('1'))),
          throwsA(isA<InvalidAmountException>()));
      expect(() => sell(const ExtraChargeInput(concept: 'Cinta', amount: Money.zero)),
          throwsA(isA<InvalidAmountException>()));
      expect((await reload(p)).stockUnits, 72, reason: 'nothing was sold');
    });

    test('box sale with an edited price keeps the suggested one and the discount',
        () async {
      final sale = await env.registerSale(lines: [
        SaleLineInput(
          productId: p.id,
          quantity: 1,
          presentation: Presentation.box,
          unitPrice: const Money(6000),
        ),
      ]);
      final line = sale.lines.single;
      expect(line.unitsBase, 24);
      expect(line.unitPrice, const Money(6000));
      expect(line.suggestedUnitPrice, const Money(6500));
      expect(line.discount, const Money(500));
      expect(line.costTotal, const Money(5600)); // 24 x 2,3333 = 55,9992
      expect(line.profit, const Money(400));
    });

    test('selling below cost records a loss', () async {
      final sale = await env.registerSale(lines: [
        SaleLineInput(
          productId: p.id,
          quantity: 10,
          presentation: Presentation.unit,
          unitPrice: const Money(200),
        ),
      ]);
      expect(sale.profit, const Money(2000 - 2333));
      expect(sale.profit.isNegative, isTrue);
    });

    test('history does not move when the price or the cost change later', () async {
      final sale = await env.registerSale(lines: [
        SaleLineInput(
          productId: p.id,
          quantity: 10,
          presentation: Presentation.unit,
        ),
      ]);
      await env.products.update((await reload(p)).copyWith(
        suggestedPriceUnit: const Money(999),
      ));
      await buy(p, 1, Presentation.box, '240'); // much more expensive

      final stored = (await env.sales.getById(sale.id))!.lines.single;
      expect(stored.unitPrice, const Money(300));
      expect(stored.suggestedUnitPrice, const Money(300));
      expect(stored.costAtSale.raw, 23333);
      expect(stored.profit, const Money(667));
    });

    test('cannot sell more than the stock and nothing is stored', () async {
      expect(
        () => env.registerSale(lines: [
          SaleLineInput(
            productId: p.id,
            quantity: 4,
            presentation: Presentation.box, // 96 units > 72
          ),
        ]),
        throwsA(isA<InsufficientStockException>()),
      );
      expect(await env.sales.getAll(), isEmpty);
      expect((await reload(p)).stockUnits, 72);
    });

    test('a failing line rolls back the whole sale', () async {
      final other = await newCandy('Twix'); // no stock
      await expectLater(
        env.registerSale(lines: [
          SaleLineInput(
            productId: p.id,
            quantity: 5,
            presentation: Presentation.unit,
          ),
          SaleLineInput(
            productId: other.id,
            quantity: 1,
            presentation: Presentation.unit,
          ),
        ]),
        throwsA(isA<InsufficientStockException>()),
      );
      expect(await env.sales.getAll(), isEmpty);
      expect((await reload(p)).stockUnits, 72);
    });

    test('two lines of the same product add up against the stock', () async {
      await expectLater(
        env.registerSale(lines: [
          SaleLineInput(
            productId: p.id,
            quantity: 2,
            presentation: Presentation.box,
          ),
          SaleLineInput(
            productId: p.id,
            quantity: 30,
            presentation: Presentation.unit,
          ),
        ]), // 48 + 30 = 78 > 72
        throwsA(isA<InsufficientStockException>()),
      );
      expect((await reload(p)).stockUnits, 72);
    });

    test('selling everything keeps the last average cost', () async {
      await env.registerSale(lines: [
        SaleLineInput(
          productId: p.id,
          quantity: 3,
          presentation: Presentation.box,
        ),
      ]);
      final after = await reload(p);
      expect(after.stockUnits, 0);
      expect(after.avgCost.raw, 23333);
    });

    test('rejects a negative price', () async {
      expect(
        () => env.registerSale(lines: [
          SaleLineInput(
            productId: p.id,
            quantity: 1,
            presentation: Presentation.unit,
            unitPrice: const Money(-1),
          ),
        ]),
        throwsA(isA<InvalidAmountException>()),
      );
    });
  });

  group('negative stock policy', () {
    test('allowNegativeStock lets the sale through', () async {
      await env.dispose();
      env = TestEnv(policy: const InventoryPolicy(allowNegativeStock: true));
      final p = await newCandy();
      await buy(p, 5, Presentation.unit, '10');

      await env.registerSale(lines: [
        SaleLineInput(
          productId: p.id,
          quantity: 8,
          presentation: Presentation.unit,
        ),
      ]);
      expect((await reload(p)).stockUnits, -3);
    });
  });

  group('stock adjustments (merma, regalo, vencido)', () {
    late Product p;

    setUp(() async {
      p = await newCandy();
      await buy(p, 1, Presentation.box, '48'); // 24 @ 2,00
    });

    test('lowers stock and records the loss at average cost', () async {
      final adj = await env.registerAdjustment(
        productId: p.id,
        quantity: 5,
        presentation: Presentation.unit,
        reason: AdjustmentReason.expired,
        notes: 'Caducó en vitrina',
      );
      expect(adj.unitsBase, 5);
      expect(adj.unitCost.raw, 20000);
      expect(adj.costTotal, const Money(1000));

      final stored = (await env.adjustments.getAll(productId: p.id)).single;
      expect(stored.reason, AdjustmentReason.expired);
      expect(stored.notes, 'Caducó en vitrina');

      final after = await reload(p);
      expect(after.stockUnits, 19);
      expect(after.avgCost.raw, 20000);
    });

    test('a whole box can be written off as own use', () async {
      await env.registerAdjustment(
        productId: p.id,
        quantity: 1,
        presentation: Presentation.box,
        reason: AdjustmentReason.ownUse,
      );
      expect((await reload(p)).stockUnits, 0);
    });

    test('cannot write off more than the stock', () async {
      expect(
        () => env.registerAdjustment(
          productId: p.id,
          quantity: 25,
          presentation: Presentation.unit,
          reason: AdjustmentReason.shrinkage,
        ),
        throwsA(isA<InsufficientStockException>()),
      );
      expect(await env.adjustments.getAll(), isEmpty);
    });
  });

  group('profitByProduct', () {
    test('groups sales per product, best first, within a date range', () async {
      final a = await newCandy('A');
      final b = await newCandy('B');
      await buy(a, 1, Presentation.box, '48'); // 24 @ 2,00
      await buy(b, 1, Presentation.box, '24'); // 24 @ 1,00

      Future<void> sell(Product p, int qty, DateTime date) =>
          env.registerSale(date: date, lines: [
            SaleLineInput(
              productId: p.id,
              quantity: qty,
              presentation: Presentation.unit,
            ),
          ]);

      await sell(a, 4, DateTime(2026, 1, 10)); // rev 12,00 cost 8,00 -> 4,00
      await sell(a, 6, DateTime(2026, 2, 10)); // rev 18,00 cost 12,00 -> 6,00
      await sell(b, 10, DateTime(2026, 1, 15)); // rev 30,00 cost 10,00 -> 20,00

      final all = await env.sales.profitByProduct();
      expect(all.map((r) => r.productName), ['B', 'A']);
      expect(all[0].unitsSold, 10);
      expect(all[0].profit, const Money(2000));
      expect(all[1].unitsSold, 10);
      expect(all[1].revenue, const Money(3000));
      expect(all[1].cost, const Money(2000));
      expect(all[1].profit, const Money(1000));

      final january = await env.sales.profitByProduct(
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 2, 1),
      );
      expect(january.map((r) => r.productName), ['B', 'A']);
      expect(january[1].unitsSold, 4);
      expect(january[1].profit, const Money(400));
    });
  });
}
