import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/domain/entities/stock_adjustment.dart';
import 'package:lucky_store/presentation/inventory/stock_write_off_page.dart';
import 'package:lucky_store/presentation/theme/app_theme.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late Product twix;

  /// Twix: boxes of 12, 30 units in stock at Bs 2,00 each.
  /// Seeded before the page listens to the database (see products_page_test).
  Future<void> pumpPage(WidgetTester tester, {bool withHistory = false}) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    await tester.runAsync(() async {
      final repo = container.read(productRepositoryProvider);
      final created = await repo.create(Product.create(name: 'Twix', unitsPerBox: 12));
      await repo.updateInventory(created.id, stockUnits: 30, avgCost: const UnitCost(20000));
      twix = (await repo.getById(created.id))!;
      if (withHistory) {
        await container.read(registerStockAdjustmentProvider)(
          productId: twix.id,
          quantity: 2,
          presentation: Presentation.unit,
          reason: AdjustmentReason.shrinkage,
          notes: 'Se cayó la caja',
        );
        twix = (await repo.getById(created.id))!;
      }
    });

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildDarkTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => StockWriteOffPage(product: twix),
                )),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  }

  Future<void> typeQuantity(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField).first, value);
    await tester.pump(const Duration(milliseconds: 100));
  }

  final submit = find.widgetWithText(FilledButton, 'Dar de baja');

  setUp(() => db = AppDatabase(NativeDatabase.memory()));

  testWidgets('offers the reasons, with no "regalo"', (tester) async {
    await pumpPage(tester);
    for (final label in ['Merma', 'Vencido', 'Consumo propio', 'Otros']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Regalo'), findsNothing);
    expect(find.textContaining('precio Bs 0'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('previews the loss and registers an expired write-off', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Vencido'));
    await tester.pump();
    await typeQuantity(tester, '5');

    expect(find.text('Se descuentan 5 u'), findsOneWidget);
    expect(find.text('Pérdida: Bs 10,00'), findsOneWidget); // 5 x 2,00
    expect(find.text('Quedan: 2 cajas + 1 u'), findsOneWidget); // 25 u

    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('abrir'), findsOneWidget, reason: 'back to the previous page');
    expect(find.textContaining('Vencido: 5 u de "Twix"'), findsOneWidget);

    final repo = container.read(productRepositoryProvider);
    final stored = (await tester.runAsync(() => repo.getById(twix.id)))!;
    expect(stored.stockUnits, 25);
    final list = (await tester.runAsync(
      () => container.read(stockAdjustmentRepositoryProvider).getAll(),
    ))!;
    expect(list.single.reason, AdjustmentReason.expired);
    expect(list.single.costTotal.cents, 1000);
    await teardown(tester);
  });

  testWidgets('writes off a whole box', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Caja (12 u)'));
    await tester.pump();

    expect(find.text('Se descuentan 12 u'), findsOneWidget);
    expect(find.text('Pérdida: Bs 24,00'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('blocks writing off more than the stock', (tester) async {
    await pumpPage(tester);
    await typeQuantity(tester, '99');

    expect(find.textContaining('Stock insuficiente: hay 30 u'), findsOneWidget);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    await teardown(tester);
  });

  testWidgets('lists previous write-offs of the product', (tester) async {
    await pumpPage(tester, withHistory: true);

    expect(find.text('Bajas anteriores'), findsOneWidget);
    expect(find.text('Merma · 2 u'), findsOneWidget);
    expect(find.textContaining('Se cayó la caja'), findsOneWidget);
    expect(find.text('-Bs 4,00'), findsOneWidget);
    await teardown(tester);
  });
}
