import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/domain/repositories/product_repository.dart';
import 'package:lucky_store/presentation/products/products_page.dart';
import 'package:lucky_store/presentation/theme/app_theme.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  /// [seed] runs in real time BEFORE the page listens to the database: while a
  /// stream is active, several writes in a row deadlock inside `runAsync`.
  Future<ProviderContainer> pumpPage(
    WidgetTester tester, {
    Future<void> Function(ProductRepository repo)? seed,
  }) async {
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    if (seed != null) {
      await tester.runAsync(() => seed(container.read(productRepositoryProvider)));
    }
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: buildDarkTheme(), home: const ProductsPage()),
    ));
    await tester.pumpAndSettle();
    return container;
  }

  setUp(() => db = AppDatabase(NativeDatabase.memory()));

  /// Unmount and dispose the container first so the stream subscriptions are
  /// cancelled; closing the database waits for them otherwise.
  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
    // Real time: closing the database needs timers that fake time never runs.
    await tester.runAsync(db.close);
  }

  testWidgets('empty state invites to create the first product', (tester) async {
    await pumpPage(tester);
    expect(find.text('Aún no tienes productos'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('creates a product with boxes from the form', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Nuevo'));
    await tester.pumpAndSettle();
    expect(find.text('Nuevo producto'), findsOneWidget);
    expect(find.text('Precio por caja'), findsNothing);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Snickers');
    await tester.tap(find.text('Se maneja por cajas'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextFormField, 'Unidades por caja'), '24');
    await tester.pump();
    expect(find.text('Precio por caja'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Precio por unidad'), '3,50');
    await tester.enterText(find.widgetWithText(TextFormField, 'Precio por caja'), '80');
    await tester.pump();
    // 24 x 3,50 = 84,00 suelto, so the box saves 4,00.
    expect(find.text('Sale a Bs 3,33 c/u · Bs 4,00 menos que por unidad'), findsOneWidget);
    await tester.ensureVisible(find.text('Crear producto'));
    await tester.tap(find.text('Crear producto'));
    await tester.pumpAndSettle();

    expect(find.text('Snickers'), findsOneWidget);
    expect(find.text('Bs 3,50 / u'), findsOneWidget);
    expect(find.text('Bs 80,00 / caja'), findsOneWidget);
    expect(find.text('Sin stock'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('validates required fields and money format', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Nuevo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear producto'));
    await tester.pumpAndSettle();
    expect(find.text('Obligatorio'), findsNWidgets(2)); // name + unit price

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Gum');
    await tester.enterText(find.widgetWithText(TextFormField, 'Precio por unidad'), '1.234');
    await tester.tap(find.text('Crear producto'));
    await tester.pumpAndSettle();
    expect(find.textContaining('máx. 2 decimales'), findsOneWidget);
    expect(find.text('Nuevo producto'), findsOneWidget, reason: 'stays on the form');
    await teardown(tester);
  });

  testWidgets('edits a product and clears its box price', (tester) async {
    final container = await pumpPage(tester);
    await tester.runAsync(() => container.read(productRepositoryProvider).create(
          Product.create(
            name: 'Twix',
            sku: 'TW',
            unitsPerBox: 12,
            suggestedPriceUnit: const Money(400),
            suggestedPriceBox: const Money(4500),
          ),
        ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Twix'));
    await tester.pumpAndSettle();
    expect(find.text('Editar producto'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Twix Caramelo');
    await tester.enterText(find.widgetWithText(TextFormField, 'Precio por caja'), '');
    await tester.scrollUntilVisible(
        find.widgetWithText(TextFormField, 'Stock mínimo (opcional)'), 200,
        scrollable: find
            .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
            .first);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Stock mínimo (opcional)'), '12');
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    final saved = (await tester.runAsync(
      () => container.read(productRepositoryProvider).getAll(),
    ))!
        .single;
    expect(saved.name, 'Twix Caramelo');
    expect(saved.suggestedPriceBox, isNull);
    expect(saved.minStockUnits, 12);
    expect(find.text('Bs 48,00 / caja'), findsOneWidget); // 12 x 4,00
    await teardown(tester);
  });

  testWidgets('swipe deletes with undo', (tester) async {
    final container = await pumpPage(tester);
    await tester.runAsync(() => container.read(productRepositoryProvider).create(
          Product.create(name: 'Hershey', suggestedPriceUnit: const Money(500)),
        ));
    await tester.pumpAndSettle();
    expect(find.text('Hershey'), findsOneWidget);

    await tester.drag(find.text('Hershey'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Hershey'), findsNothing);
    expect(find.text('Deshacer'), findsOneWidget);

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(find.text('Hershey'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('search filters by name or sku', (tester) async {
    await pumpPage(tester, seed: (repo) async {
      await repo.create(Product.create(name: 'Twix', sku: 'CHOC-1'));
      await repo.create(Product.create(name: 'Gomitas', sku: 'GOM-9'));
    });

    // Not pumpAndSettle: the focused field's blinking cursor never settles.
    await tester.enterText(find.byType(TextField), 'gom');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Gomitas'), findsOneWidget);
    expect(find.text('Twix'), findsNothing);

    await tester.enterText(find.byType(TextField), 'choc');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Twix'), findsOneWidget);
    expect(find.text('Gomitas'), findsNothing);
    await teardown(tester);
  });

  testWidgets('cards show stock, cost and what each unit leaves; filters',
      (tester) async {
    await pumpPage(tester, seed: (repo) async {
      final s = await repo.create(Product.create(
        name: 'Snickers',
        unitsPerBox: 24,
        suggestedPriceUnit: const Money(300),
        minStockUnits: 30,
      ));
      await repo.updateInventory(s.id, stockUnits: 26, avgCost: const UnitCost(20000));
      await repo.create(Product.create(name: 'Gomitas', suggestedPriceUnit: const Money(100)));
    });

    // Snickers: 26 u (1 box + 2), cost 2,00, leaves 1,00 per unit (33%).
    expect(find.text('Stock bajo'), findsOneWidget);
    expect(find.text('1 caja + 2 u'), findsOneWidget);
    expect(find.text('Bs 2,0000'), findsOneWidget);
    expect(find.text('Bs 1,00'), findsOneWidget);
    expect(find.text('33% margen'), findsOneWidget);
    expect(find.text('Sin stock'), findsOneWidget, reason: 'Gomitas');
    expect(find.text('En stock: Bs 52,00'), findsOneWidget);

    await tester.tap(find.text('Stock bajo (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Snickers'), findsOneWidget);
    expect(find.text('Gomitas'), findsNothing);

    await tester.tap(find.text('Sin stock (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Snickers'), findsNothing);
    expect(find.text('Gomitas'), findsOneWidget);
    expect(find.text('1 de 2 productos'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('the product explains its cost and profit at phone width',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpPage(tester, seed: (repo) async {
      final p = await repo.create(Product.create(
        name: 'Snickers',
        unitsPerBox: 24,
        suggestedPriceUnit: const Money(300),
        suggestedPriceBox: const Money(6500),
      ));
      await repo.updateInventory(
        p.id,
        stockUnits: 60,
        avgCost: const UnitCost(20400),
      );
    });
    expect(tester.takeException(), isNull, reason: 'list fits');

    await tester.tap(find.text('Snickers'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Por caja (24 u) · precio Bs 65,00'),
      200,
      scrollable: find
          .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
          .first,
    );

    expect(find.text('Cómo se calcula'), findsOneWidget);
    expect(find.text('Valor en stock'), findsOneWidget);
    expect(find.text('Bs 122,40'), findsWidgets);
    expect(find.text('Por unidad · precio Bs 3,00'), findsOneWidget);
    expect(find.text('Bs 0,96'), findsOneWidget);
    expect(find.text('Costo (24 u × Bs 2,0400)'), findsOneWidget);
    expect(find.text('Bs 16,04'), findsOneWidget);
    expect(find.text('Ganancia · 25% del precio'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'formula fits');
    await teardown(tester);
  });
}
