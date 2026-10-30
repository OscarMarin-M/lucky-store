import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/domain/entities/stock_adjustment.dart';
import 'package:lucky_store/domain/purchasing/purchase_lot.dart';
import 'package:lucky_store/domain/usecases/register_purchase.dart';
import 'package:lucky_store/domain/usecases/register_sale.dart';
import 'package:lucky_store/presentation/format/date_format.dart';
import 'package:lucky_store/presentation/home/home_page.dart';
import 'package:lucky_store/presentation/theme/app_theme.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final expiry = today.add(const Duration(days: 10));

  Future<void> pumpPage(WidgetTester tester, {bool seed = true}) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    // Seeded before the page listens to the database (see products_page_test).
    if (seed) {
      await tester.runAsync(() async {
        final p = await container.read(productRepositoryProvider).create(
              Product.create(
                name: 'Snickers',
                unitsPerBox: 24,
                suggestedPriceUnit: const Money(300),
                minStockUnits: 30,
              ),
            );
        // Bought 40 days ago: outside "Hoy", inside "Todo".
        await container.read(registerPurchaseProvider)(
          date: today.subtract(const Duration(days: 40)),
          lines: [
            PurchaseLineInput(
              productId: p.id,
              lot: BoxLot(
                boxes: 1,
                unitsPerBox: 24,
                pricePerBox: const Money(4800), // Bs 2,00 c/u
                expiry: expiry,
              ),
            ),
          ],
        );
        // Today: 10 u at Bs 3,00 (+10) and 1 u written off (-2).
        await container.read(registerSaleProvider)(lines: [
          SaleLineInput(
            productId: p.id,
            quantity: 10,
            presentation: Presentation.unit,
          ),
        ]);
        await container.read(registerStockAdjustmentProvider)(
          productId: p.id,
          quantity: 1,
          presentation: Presentation.unit,
          reason: AdjustmentReason.shrinkage,
        );
      });
    }
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: buildDarkTheme(), home: const HomePage()),
    ));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  }

  setUp(() => db = AppDatabase(NativeDatabase.memory()));

  testWidgets('empty shop', (tester) async {
    await pumpPage(tester, seed: false);
    expect(find.text('Sin ventas en este período'), findsOneWidget);
    expect(find.text('Valor en stock: Bs 0,00'), findsOneWidget);
    expect(find.text('Atención'), findsNothing);
    await teardown(tester);
  });

  testWidgets('today: sales, real profit, alerts and inventory', (tester) async {
    await pumpPage(tester);

    expect(find.text('Bs 30,00'), findsOneWidget); // sales
    expect(find.text('1 venta'), findsOneWidget);
    // Profit after the write-off, in the card and in the product row.
    expect(find.text('Bs 8,00'), findsNWidgets(2));
    expect(find.text('ya restadas las bajas'), findsOneWidget);
    expect(find.text('Bs 2,00'), findsOneWidget); // write-off loss

    expect(find.text('10 u · Bs 30,00 · bajas -Bs 2,00'), findsOneWidget);
    expect(find.text('27% margen'), findsOneWidget);

    // 13 u left: the lot expiring in 10 days, and under the minimum of 30.
    expect(find.text('Atención'), findsOneWidget);
    expect(
      find.text('Un lote vence en 10 días (${formatDate(expiry)}) · '
          'tienes 13 u de ese lote'),
      findsOneWidget,
    );
    expect(find.text('Stock bajo: 13 u (mínimo 30 u)'), findsOneWidget);
    expect(find.text('Valor en stock: Bs 26,00'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('the period changes the money, not the alerts', (tester) async {
    await pumpPage(tester);
    expect(find.text('Bs 0,00'), findsOneWidget, reason: 'no purchase today');

    await tester.tap(find.text('Todo'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('Bs 48,00'), findsOneWidget);
    expect(find.text('Stock bajo: 13 u (mínimo 30 u)'), findsOneWidget);
    await teardown(tester);
  });
}
