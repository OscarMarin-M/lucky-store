import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/domain/repositories/product_repository.dart';
import 'package:lucky_store/presentation/purchases/purchase_page.dart';
import 'package:lucky_store/presentation/theme/app_theme.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  /// Seeds BEFORE the page listens to the database (see products_page_test).
  Future<void> pumpPage(
    WidgetTester tester, {
    required Future<void> Function(ProductRepository repo) seed,
  }) async {
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    await tester.runAsync(() => seed(container.read(productRepositoryProvider)));
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: buildDarkTheme(), home: const PurchasePage()),
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

  setUp(() => db = AppDatabase(NativeDatabase.memory()));

  testWidgets('buys 2 boxes and updates the product stock and cost', (tester) async {
    late Product snickers;
    await pumpPage(tester, seed: (repo) async {
      snickers = await repo.create(Product.create(name: 'Snickers', unitsPerBox: 24));
    });

    expect(find.text('Agrega los productos que compraste'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    await tester.tap(find.text('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Snickers'));
    await tester.pumpAndSettle();

    // Line card: a box of the product's usual size, 1 -> 2 boxes with "+".
    expect(find.text('Caja'), findsOneWidget);
    expect(find.text('Por unidades'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.widgetWithText(TextField, 'Unidades por caja'))
          .controller!.text,
      '24',
    );
    await tester.tap(find.byTooltip('Más'));
    await tester.pump();
    // Price of ONE box; total and unit cost are derived.
    await tester.enterText(find.widgetWithText(TextField, 'Precio por caja'), '48');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Total (48 u)'), findsOneWidget);
    expect(find.text('Bs 96,00'), findsNWidgets(2)); // line total + footer
    expect(find.text('Sale a'), findsOneWidget);
    expect(find.text('Bs 2,0000 c/u'), findsOneWidget);
    expect(find.text('Costo promedio: Bs 2,0000'), findsOneWidget);

    await tester.tap(find.text('Registrar compra'));
    await tester.pumpAndSettle();

    expect(find.text('Compra registrada · Bs 96,00'), findsOneWidget);
    expect(find.text('Agrega los productos que compraste'), findsOneWidget);

    final stored = (await tester.runAsync(
      () => container.read(productRepositoryProvider).getById(snickers.id),
    ))!;
    expect(stored.stockUnits, 48);
    expect(stored.avgCost.raw, 20000);
    await teardown(tester);
  });

  testWidgets('shows how the average cost moves on a second purchase', (tester) async {
    await pumpPage(tester, seed: (repo) async {
      final p = await repo.create(Product.create(name: 'Twix', unitsPerBox: 12));
      await repo.updateInventory(
        p.id,
        stockUnits: 12,
        avgCost: const UnitCost(20000), // Bs 2,00 per unit
      );
    });

    await tester.tap(find.text('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Twix'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Precio por caja'), '36');
    await tester.pump(const Duration(milliseconds: 100));

    // 12 u @ 2,00 + 12 u @ 3,00 => 2,50
    expect(find.text('Costo promedio pasa de Bs 2,0000 a Bs 2,5000'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('informal purchase: loose units from the money spent', (tester) async {
    late Product snickers;
    await pumpPage(tester, seed: (repo) async {
      snickers = await repo.create(Product.create(name: 'Snickers', unitsPerBox: 24));
    });

    await tester.tap(find.text('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Snickers'));
    await tester.pumpAndSettle();

    // Ask how it was bought: the form changes to the loose-units one.
    await tester.tap(find.text('Por unidades'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Precio por caja'), findsNothing);
    expect(find.text('Vence desde (opcional)'), findsOneWidget);
    expect(find.text('hasta (opcional)'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Precio por unidad'), '2,50');
    await tester.pump();
    await tester.tap(find.text('Monto pagado'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Monto pagado'), '25');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Total (10 u)'), findsOneWidget);
    expect(find.text('Unidades'), findsOneWidget);

    await tester.tap(find.text('Registrar compra'));
    await tester.pumpAndSettle();
    expect(find.text('Compra registrada · Bs 25,00'), findsOneWidget);

    final stored = (await tester.runAsync(
      () => container.read(productRepositoryProvider).getById(snickers.id),
    ))!;
    expect(stored.stockUnits, 10);
    expect(stored.avgCost.raw, 25000);
    await teardown(tester);
  });

  testWidgets('a product can be created from the picker and added', (tester) async {
    await pumpPage(tester, seed: (_) async {});

    await tester.tap(find.text('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear producto nuevo'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Gomitas');
    await tester.enterText(find.widgetWithText(TextFormField, 'Por unidad'), '1');
    await tester.tap(find.text('Crear producto'));
    await tester.pumpAndSettle();

    expect(find.text('Comprar'), findsOneWidget);
    expect(find.text('Gomitas'), findsOneWidget, reason: 'added to the draft');
    await teardown(tester);
  });
}
