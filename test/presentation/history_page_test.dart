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
import 'package:lucky_store/presentation/history/history_page.dart';
import 'package:lucky_store/presentation/theme/app_theme.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> pumpPage(
    WidgetTester tester, {
    bool seed = true,
    String? user,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      currentUserProvider.overrideWithValue(() => user),
    ]);
    // Seeded before the page listens to the database (see products_page_test).
    if (seed) {
      await tester.runAsync(() async {
        final now = DateTime.now();
        DateTime at(int hour) => DateTime(now.year, now.month, now.day, hour);
        final p = await container.read(productRepositoryProvider).create(
              Product.create(
                name: 'Snickers',
                unitsPerBox: 24,
                suggestedPriceUnit: const Money(300),
              ),
            );
        // A box of 36 (this supplier's size) at Bs 72 => Bs 2,00 c/u.
        await container.read(registerPurchaseProvider)(
          date: at(8),
          supplier: 'Distribuidora Sur',
          lines: [
            PurchaseLineInput(
              productId: p.id,
              lot: BoxLot(
                boxes: 1,
                unitsPerBox: 36,
                pricePerBox: const Money(7200),
                expiry: DateTime(2027, 3, 15),
                lotCode: 'L-9',
              ),
            ),
          ],
        );
        // 10 u at the suggested Bs 3,00 (+10) and one gift (-2) => +8.
        await container.read(registerSaleProvider)(date: at(10), lines: [
          SaleLineInput(
            productId: p.id,
            quantity: 10,
            presentation: Presentation.unit,
          ),
          SaleLineInput(
            productId: p.id,
            quantity: 1,
            presentation: Presentation.unit,
            unitPrice: Money.zero,
          ),
        ]);
        await container.read(registerStockAdjustmentProvider)(
          productId: p.id,
          date: at(9),
          quantity: 1,
          presentation: Presentation.unit,
          reason: AdjustmentReason.expired,
        );
      });
    }
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: buildDarkTheme(), home: const HistoryPage()),
    ));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
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

  testWidgets('empty history', (tester) async {
    await pumpPage(tester, seed: false);
    expect(find.text('Aquí aparecerán tus ventas, compras y bajas'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('one day with a sale, a write-off and a purchase', (tester) async {
    await pumpPage(tester);

    expect(find.text('Hoy'), findsOneWidget);
    // Day profit = sale (+8) - write-off loss (2).
    expect(find.textContaining('ganancia Bs 6,00'), findsOneWidget);
    expect(find.text('10:00 · Venta'), findsOneWidget);
    expect(find.text('+Bs 8,00'), findsOneWidget);
    expect(find.text('09:00 · Baja · Vencido · 1 u'), findsOneWidget);
    expect(find.text('-Bs 2,00'), findsOneWidget);
    expect(
      find.text('08:00 · Compra · Distribuidora Sur · vence 15/03/2027'),
      findsOneWidget,
    );

    await tester.tap(find.text('Compras'));
    await tester.pumpAndSettle();
    expect(find.text('10:00 · Venta'), findsNothing);
    expect(find.textContaining('08:00 · Compra'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('purchase detail shows the lot; sale detail the gift', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.textContaining('08:00 · Compra'));
    await tester.pumpAndSettle();
    expect(find.text('1 caja de 36 u × Bs 72,00'), findsOneWidget);
    expect(find.text('Bs 2,0000 c/u'), findsOneWidget);
    expect(find.text('Vence 15/03/2027'), findsOneWidget);
    expect(find.text('Código L-9'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('10:00 · Venta'));
    await tester.pumpAndSettle();
    expect(find.text('10 u × Bs 3,00'), findsOneWidget);
    expect(find.text('1 u · Regalo'), findsOneWidget);
    expect(find.text('Bs 8,00'), findsOneWidget); // profit of the sale
    await teardown(tester);
  });

  testWidgets('shows who registered each document', (tester) async {
    await pumpPage(tester, user: 'ana.perez@gmail.com');

    // The list only has room for the name before the @.
    expect(find.text('10:00 · Venta · ana.perez'), findsOneWidget);
    expect(find.text('09:00 · Baja · Vencido · 1 u · ana.perez'), findsOneWidget);
    expect(
      find.textContaining('08:00 · Compra · ana.perez · Distribuidora Sur'),
      findsOneWidget,
    );

    await tester.tap(find.text('10:00 · Venta · ana.perez'));
    await tester.pumpAndSettle();
    expect(find.text('Registrado por ana.perez@gmail.com'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('voiding a sale: crossed out, out of the day totals, stock back',
      (tester) async {
    await pumpPage(tester, user: 'ana.perez@gmail.com');
    expect(find.textContaining('ganancia Bs 6,00'), findsOneWidget);

    await tester.tap(find.text('10:00 · Venta · ana.perez'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Anular venta'));
    await tester.pumpAndSettle();
    expect(find.text('¿Anular esta venta?'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Motivo (opcional)'),
      'Me equivoqué de producto',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Anular'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    // Back on the list: still there, crossed out, and the day only counts
    // the write-off now (no sales left to show totals for).
    expect(find.text('Venta anulada'), findsOneWidget);
    expect(find.text('Anulada · 10:00 · Venta · ana.perez'), findsOneWidget);
    expect(find.textContaining('ganancia'), findsNothing);

    final snickers = (await tester.runAsync(
      () => container.read(productRepositoryProvider).getAll(),
    ))!
        .single;
    expect(snickers.stockUnits, 35, reason: '36 bought - 1 written off');

    await tester.tap(find.text('Anulada · 10:00 · Venta · ana.perez'));
    await tester.pumpAndSettle();
    expect(find.text('Anulada · no cuenta en stock ni ganancias'), findsOneWidget);
    expect(find.textContaining(' · por ana.perez@gmail.com'), findsOneWidget);
    expect(find.text('Motivo: Me equivoqué de producto'), findsOneWidget);
    expect(find.byTooltip('Anular venta'), findsNothing);
    await teardown(tester);
  });

  testWidgets('voiding a purchase already sold warns about negative stock',
      (tester) async {
    await pumpPage(tester);
    // The box brought 36 u and 24 remain: voiding it leaves -12.
    await tester.tap(find.textContaining('08:00 · Compra'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Anular compra'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Snickers quedará con stock -12 u (ya se vendieron unidades de esta compra).',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Anular compra'), findsOneWidget, reason: 'kept');
    await teardown(tester);
  });
}
