import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/presentation/sales/sale_page.dart';
import 'package:lucky_store/presentation/theme/app_theme.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late Product gum;

  /// Gum: 10 units @ Bs 2,00, sold at Bs 3,00. Twix: no stock.
  /// Seeded before the page listens to the database (see products_page_test).
  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    await tester.runAsync(() async {
      final repo = container.read(productRepositoryProvider);
      final g = await repo.create(Product.create(name: 'Gum', suggestedPriceUnit: const Money(300)));
      await repo.updateInventory(g.id, stockUnits: 10, avgCost: const UnitCost(20000));
      gum = (await repo.getById(g.id))!;
      await repo.create(Product.create(name: 'Twix', suggestedPriceUnit: const Money(500)));
    });
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: buildDarkTheme(), home: const SalePage()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  }

  Future<void> addGum(WidgetTester tester) async {
    await tester.tap(find.text('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gum'));
    await tester.pumpAndSettle();
  }

  final charge = find.widgetWithText(FilledButton, 'Cobrar');

  setUp(() => db = AppDatabase(NativeDatabase.memory()));

  testWidgets('picker shows prices and disables products without stock', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Agregar producto'));
    await tester.pumpAndSettle();

    expect(find.text('Crear producto nuevo'), findsNothing);
    expect(find.text('Bs 3,00'), findsOneWidget);
    final twixTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Twix'));
    expect(twixTile.enabled, isFalse);
    await teardown(tester);
  });

  testWidgets('sells 2 units and reports the profit', (tester) async {
    await pumpPage(tester);
    expect(tester.widget<FilledButton>(charge).onPressed, isNull);

    await addGum(tester);
    await tester.tap(find.byTooltip('Más'));
    await tester.pump();

    expect(find.text('Bs 6,00'), findsNWidgets(2)); // line subtotal + footer
    expect(find.text('Ganancia Bs 2,00'), findsOneWidget);

    await tester.tap(charge);
    await tester.pumpAndSettle();

    expect(find.text('Venta registrada · Bs 6,00 · ganancia Bs 2,00'), findsOneWidget);
    expect(find.text('Agrega productos al carrito'), findsOneWidget);
    final stored = (await tester.runAsync(
      () => container.read(productRepositoryProvider).getById(gum.id),
    ))!;
    expect(stored.stockUnits, 8);
    await teardown(tester);
  });

  testWidgets('edited price shows the discount; gift sets price 0', (tester) async {
    await pumpPage(tester);
    await addGum(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Precio por unidad'), '2,50');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Descuento Bs 0,50 (sugerido Bs 3,00)'), findsOneWidget);

    await tester.tap(find.text('Regalo'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Regalo: el costo cuenta'), findsOneWidget);
    expect(find.text('Ganancia -Bs 2,00'), findsOneWidget);
    expect(tester.widget<FilledButton>(charge).onPressed, isNotNull);
    await teardown(tester);
  });

  testWidgets('blocks charging more than the stock', (tester) async {
    await pumpPage(tester);
    await addGum(tester);

    await tester.enterText(find.byType(TextField).first, '11');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Stock insuficiente: hay 10 u y el carrito pide 11 u'), findsOneWidget);
    expect(tester.widget<FilledButton>(charge).onPressed, isNull);
    await teardown(tester);
  });
}
