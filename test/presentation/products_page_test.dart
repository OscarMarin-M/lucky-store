import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/money/money.dart';
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
    expect(find.text('Por caja'), findsNothing);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Snickers');
    await tester.enterText(find.widgetWithText(TextFormField, 'Unidades por caja'), '24');
    await tester.pump();
    expect(find.text('Por caja'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Por unidad'), '3,50');
    await tester.enterText(find.widgetWithText(TextFormField, 'Por caja'), '80');
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
    await tester.enterText(find.widgetWithText(TextFormField, 'Por unidad'), '1.234');
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
    await tester.enterText(find.widgetWithText(TextFormField, 'Por caja'), '');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    final saved = (await tester.runAsync(
      () => container.read(productRepositoryProvider).getAll(),
    ))!
        .single;
    expect(saved.name, 'Twix Caramelo');
    expect(saved.suggestedPriceBox, isNull);
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
}
