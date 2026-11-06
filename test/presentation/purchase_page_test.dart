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
    expect(find.text('Por unidad'), findsOneWidget);
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
    // Line total, footer, and twice in the formula (result of the total,
    // then divided by the units).
    expect(find.text('Bs 96,00'), findsNWidgets(4));
    expect(find.text('Sale a'), findsOneWidget);
    expect(find.text('Bs 2,0000 c/u'), findsOneWidget);
    expect(find.text('Cómo se calcula'), findsOneWidget);
    expect(find.text('2 cajas'), findsOneWidget);
    expect(find.text('Costo por unidad'), findsOneWidget);
    expect(find.text('48 u'), findsOneWidget);
    expect(
      find.textContaining('No había stock: el costo promedio queda en el de este lote, Bs 2,0000'),
      findsOneWidget,
    );

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
    tester.view.physicalSize = const Size(360, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
    expect(find.text('Mezcla con lo que ya tenías'), findsOneWidget);
    expect(find.text('En stock: 12 u × Bs 2,0000'), findsOneWidget);
    expect(find.text('Este lote: 12 u × Bs 3,0000'), findsOneWidget);
    expect(find.text('Bs 60,00'), findsOneWidget, reason: 'pooled value');
    expect(find.text('24 u'), findsOneWidget, reason: 'pooled units');
    expect(find.text('Bs 2,5000'), findsOneWidget, reason: 'new average');
    expect(tester.takeException(), isNull, reason: 'fits a 360 dp phone');
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
    await tester.tap(find.text('Por unidad'));
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
    await tester.enterText(find.widgetWithText(TextFormField, 'Precio por unidad'), '1');
    await tester.tap(find.text('Crear producto'));
    await tester.pumpAndSettle();

    expect(find.text('Comprar'), findsOneWidget);
    expect(find.text('Gomitas'), findsOneWidget, reason: 'added to the draft');
    await teardown(tester);
  });

  testWidgets('informal bag: the units per bag are asked, not assumed (v10)',
      (tester) async {
    late Product snickers;
    await pumpPage(tester, seed: (repo) async {
      snickers = await repo.create(Product.create(name: 'Snickers', unitsPerBox: 24));
    });

    await tester.tap(find.text('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Snickers'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bolsa'));
    await tester.pumpAndSettle();
    final size = find.widgetWithText(TextField, 'Unidades por bolsa');
    expect(tester.widget<TextField>(size).controller!.text, isEmpty);

    await tester.enterText(size, '25');
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Precio por bolsa'), '20');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Total (25 u)'), findsOneWidget);
    expect(find.text('Bs 0,8000 c/u'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'three options fit a 360 dp phone');

    await tester.tap(find.text('Registrar compra'));
    await tester.pumpAndSettle();
    final stored = (await tester.runAsync(
      () => container.read(productRepositoryProvider).getById(snickers.id),
    ))!;
    expect(stored.stockUnits, 25);
    expect(stored.unitsPerBag, isNull, reason: 'a purchase never sets the default');
    await teardown(tester);
  });
}
