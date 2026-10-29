import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/presentation/sales/sale_draft.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  /// Box of 24, Bs 3,00 per unit / Bs 65,00 per box, 48 units @ Bs 2,00.
  late Product snickers;

  SaleDraft draft() => container.read(saleDraftProvider.notifier);
  SaleDraftState state() => container.read(saleDraftProvider);
  bool canSubmit() => state().canSubmit(allowNegativeStock: false);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    final repo = container.read(productRepositoryProvider);
    final p = await repo.create(Product.create(
      name: 'Snickers',
      unitsPerBox: 24,
      suggestedPriceUnit: const Money(300),
      suggestedPriceBox: const Money(6500),
    ));
    await repo.updateInventory(p.id, stockUnits: 48, avgCost: const UnitCost(20000));
    snickers = (await repo.getById(p.id))!;
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  String firstId() => state().lines.first.id;

  test('a new line is one unit at the suggested price', () {
    draft().addProduct(snickers);
    final line = state().lines.single;
    expect(line.presentation, Presentation.unit);
    expect(line.priceText, '3,00');
    expect(line.lineTotal, const Money(300));
    expect(canSubmit(), isTrue);
  });

  test('switching to box resets the price to the box suggested price', () {
    draft().addProduct(snickers);
    draft().setPrice(firstId(), '2,50');
    draft().setPresentation(firstId(), Presentation.box);
    final line = state().lines.single;
    expect(line.priceText, '65,00');
    expect(line.unitsBase, 24);
  });

  test('discount and estimated profit', () {
    draft().addProduct(snickers);
    draft()
      ..setQuantity(firstId(), 10)
      ..setPrice(firstId(), '2,50');
    final line = state().lines.single;
    expect(line.lineTotal, const Money(2500));
    expect(line.discount, const Money(500)); // (3,00 - 2,50) x 10
    expect(line.estimatedProfit, const Money(500)); // 25,00 - 10 x 2,00
  });

  test('gift toggles price 0 and back to the suggested price', () {
    draft().addProduct(snickers);
    draft().toggleGift(firstId());
    expect(state().lines.single.isGift, isTrue);
    expect(state().lines.single.lineTotal, Money.zero);
    expect(state().lines.single.estimatedProfit, const Money(-200));
    expect(canSubmit(), isTrue, reason: 'a gift is a valid line');

    draft().toggleGift(firstId());
    expect(state().lines.single.priceText, '3,00');
  });

  test('lines of the same product add up against the stock', () {
    draft()
      ..addProduct(snickers)
      ..addProduct(snickers);
    final a = state().lines[0].id;
    draft().setPresentation(a, Presentation.box);
    draft().setQuantity(a, 2); // 48 units
    expect(state().unitsByProduct[snickers.id], 49);
    expect(state().fitsStock(snickers, allowNegativeStock: false), isFalse);
    expect(canSubmit(), isFalse);
    expect(state().canSubmit(allowNegativeStock: true), isTrue);
  });

  test('invalid price or quantity blocks the sale', () {
    draft().addProduct(snickers);
    draft().setPrice(firstId(), 'abc');
    expect(canSubmit(), isFalse);
    draft()
      ..setPrice(firstId(), '3')
      ..setQuantity(firstId(), 0);
    expect(canSubmit(), isFalse);
  });

  test('submit registers the sale with a gift line and empties the cart', () async {
    draft()
      ..addProduct(snickers)
      ..addProduct(snickers);
    final a = state().lines[0].id;
    final b = state().lines[1].id;
    draft()
      ..setQuantity(a, 10)
      ..toggleGift(b);

    final sale = await draft().submit();

    expect(sale.total, const Money(3000));
    // 30,00 - 10 x 2,00 on the sold line, -2,00 for the gift.
    expect(sale.profit, const Money(800));
    expect(sale.lines[1].unitPrice, Money.zero);
    expect(sale.lines[1].suggestedUnitPrice, const Money(300));
    final stored = (await container.read(productRepositoryProvider).getById(snickers.id))!;
    expect(stored.stockUnits, 37);
    expect(state().lines, isEmpty);
  });

  test('a rejected sale keeps the cart', () async {
    draft().addProduct(snickers);
    // Stock disappears after the line was added.
    await container
        .read(productRepositoryProvider)
        .updateInventory(snickers.id, stockUnits: 0, avgCost: const UnitCost(20000));

    await expectLater(draft().submit(), throwsA(isA<InsufficientStockException>()));
    expect(state().lines, hasLength(1));
  });
}
