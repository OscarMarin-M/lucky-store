import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/money/unit_cost.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/presentation/sales/quote_sheet.dart';
import 'package:lucky_store/presentation/sales/sale_page.dart';
import 'package:lucky_store/presentation/theme/app_theme.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late Product gum;

  /// Gum: 10 units @ Bs 2,00, sold at Bs 3,00. Twix: no stock. Skittles:
  /// bags of 30.
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
      // Skittles: bags of 30 (Bs 25,00 the bag), 60 units @ Bs 0,60.
      final s = await repo.create(Product.create(
        name: 'Skittles',
        suggestedPriceUnit: const Money(100),
        unitsPerBag: 30,
        suggestedPriceBag: const Money(2500),
      ));
      await repo.updateInventory(s.id, stockUnits: 60, avgCost: const UnitCost(6000));
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

  testWidgets('an order with a name and an extra charge', (tester) async {
    await pumpPage(tester);
    await addGum(tester);
    await tester.tap(find.byTooltip('Más')); // 2 u: Bs 6,00, profit Bs 2,00
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del pedido o nota (opcional)'),
      'Caja para Ana',
    );
    await tester.tap(find.text('Mano de obra'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Monto'), '1,50');
    await tester.pump();
    await tester.ensureVisible(find.text('Lo paga el cliente'));
    await tester.tap(find.text('Lo paga el cliente'));
    await tester.pump();

    expect(find.text('Cargos y costos adicionales'), findsOneWidget);
    expect(find.text('Incluye cargos al cliente'), findsOneWidget);
    expect(find.text('+Bs 1,50'), findsOneWidget);
    expect(find.text('Bs 7,50'), findsOneWidget, reason: 'total with the charge');
    expect(find.text('Bs 3,50'), findsOneWidget, reason: 'estimated profit');

    await tester.tap(charge);
    await tester.pumpAndSettle();
    expect(find.text('Venta registrada · Bs 7,50 · ganancia Bs 3,50'), findsOneWidget);

    final sale = (await tester.runAsync(
      () => container.read(saleRepositoryProvider).getAll(),
    ))!
        .single;
    expect(sale.notes, 'Caja para Ana');
    expect(sale.extraCharges.single.concept, 'Mano de obra');
    expect(sale.extraCharges.single.amount, const Money(150));
    await teardown(tester);
  });

  testWidgets('a quote copies the customer text and registers nothing',
      (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    // A phone without WhatsApp: only the copy button.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      shareChannel,
      (call) async => <String>[],
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(shareChannel, null));

    await pumpPage(tester);
    final quote = find.widgetWithText(OutlinedButton, 'Cotización');
    expect(tester.widget<OutlinedButton>(quote).onPressed, isNull,
        reason: 'empty cart');
    await addGum(tester);
    await tester.tap(find.byTooltip('Más')); // 2 u: Bs 6,00
    await tester.pump();
    await tester.tap(find.text('Empaque')); // paid by the shop: not shown
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Monto'), '0,50');
    await tester.pump();

    await tester.tap(quote);
    await tester.pumpAndSettle();
    final shown = tester.widget<SelectableText>(find.byType(SelectableText)).data!;
    expect(shown, contains('2 × Gum — Bs 3,00 c/u = Bs 6,00'));
    expect(shown, isNot(contains('Empaque')));
    expect(find.text('WhatsApp'), findsNothing);

    await tester.tap(find.text('Copiar texto'));
    await tester.pumpAndSettle();
    expect(copied, contains('*Total: Bs 6,00*'));
    expect(find.text('Cotización copiada: pégala en el chat del cliente'),
        findsOneWidget);
    expect(find.text('Gum'), findsOneWidget, reason: 'the cart stays');

    final sales = await tester.runAsync(
      () => container.read(saleRepositoryProvider).getAll(),
    );
    expect(sales, isEmpty);
    await teardown(tester);
  });

  testWidgets('a quote offers each installed WhatsApp and sends to the one tapped',
      (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      shareChannel,
      (call) async {
        calls.add(call);
        return call.method == 'installedApps'
            ? ['com.whatsapp', 'com.whatsapp.w4b']
            : true;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(shareChannel, null));

    await pumpPage(tester);
    await addGum(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cotización'));
    await tester.pumpAndSettle();
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('WhatsApp Business'), findsOneWidget);

    await tester.tap(find.text('WhatsApp Business'));
    await tester.pumpAndSettle();
    final sent = calls.last;
    expect(sent.method, 'sendText');
    expect(sent.arguments['package'], 'com.whatsapp.w4b');
    expect(sent.arguments['text'], contains('1 × Gum — Bs 3,00'));
    expect(find.text('Copiar texto'), findsNothing, reason: 'sheet closed');
    await teardown(tester);
  });

  testWidgets('an extra cost is paid by the shop unless changed',
      (tester) async {
    await pumpPage(tester);
    await addGum(tester);
    await tester.tap(find.byTooltip('Más')); // 2 u: Bs 6,00, profit Bs 2,00
    await tester.pump();

    await tester.tap(find.text('Empaque'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Monto'), '0,50');
    await tester.pump();

    expect(find.text('Costos que paga la tienda'), findsOneWidget);
    expect(find.text('-Bs 0,50'), findsOneWidget);
    expect(find.text('Bs 6,00'), findsNWidgets(2),
        reason: 'total unchanged: same as the line');
    expect(find.text('Bs 1,50'), findsOneWidget, reason: 'estimated profit');

    await tester.tap(charge);
    await tester.pumpAndSettle();
    expect(find.text('Venta registrada · Bs 6,00 · ganancia Bs 1,50'), findsOneWidget);

    final sale = (await tester.runAsync(
      () => container.read(saleRepositoryProvider).getAll(),
    ))!
        .single;
    expect(sale.extraCharges.single.paidByCustomer, isFalse);
    await teardown(tester);
  });

  testWidgets('sells a whole bag at the bag price (v10)', (tester) async {
    await pumpPage(tester);
    await addGum(tester);
    expect(find.text('Unidad'), findsNothing, reason: 'gum: units only');

    await tester.tap(find.text('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skittles'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bolsa (30 u)'));
    await tester.pump(const Duration(milliseconds: 100));

    final price = find.widgetWithText(TextField, 'Precio por bolsa');
    expect(tester.widget<TextField>(price).controller!.text, '25,00');
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Quitar').first); // drop the gum
    await tester.pumpAndSettle();
    await tester.tap(charge);
    await tester.pumpAndSettle();
    // 25,00 - 30 x 0,60
    expect(find.text('Venta registrada · Bs 25,00 · ganancia Bs 7,00'), findsOneWidget);
    final stored = (await tester.runAsync(
      () => container.read(productRepositoryProvider).getAll(),
    ))!;
    expect(stored.singleWhere((p) => p.name == 'Skittles').stockUnits, 30);
    await teardown(tester);
  });
}
