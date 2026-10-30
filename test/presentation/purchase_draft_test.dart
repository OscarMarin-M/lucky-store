import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/errors/domain_exception.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/presentation/purchases/purchase_draft.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late Product snickers; // box of 24
  late Product gum; // no boxes

  PurchaseDraft draft() => container.read(purchaseDraftProvider.notifier);
  PurchaseDraftState state() => container.read(purchaseDraftProvider);
  DraftPurchaseLine line([int i = 0]) => state().lines[i];

  /// Edits the box form of line [i].
  void box(BoxLotForm Function(BoxLotForm f) edit, [int i = 0]) =>
      draft().updateForm(line(i).id, edit(line(i).form as BoxLotForm));

  /// Edits the loose-units form of line [i].
  void loose(LooseLotForm Function(LooseLotForm f) edit, [int i = 0]) =>
      draft().updateForm(line(i).id, edit(line(i).form as LooseLotForm));

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    final products = container.read(productRepositoryProvider);
    snickers = await products.create(Product.create(name: 'Snickers', unitsPerBox: 24));
    gum = await products.create(Product.create(name: 'Gum'));
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('a product with boxes starts as a box of its usual size', () {
    draft()
      ..addProduct(snickers)
      ..addProduct(gum);
    expect(line(0).mode, Presentation.box);
    expect((line(0).form as BoxLotForm).unitsPerBoxText, '24');
    expect(line(1).mode, Presentation.unit);
  });

  test('box: price of one box x boxes, with the size of THIS box', () {
    draft().addProduct(snickers);
    expect(state().canSubmit, isFalse, reason: 'no price yet');

    box((f) => f.copyWith(boxes: 2, priceText: '72', unitsPerBoxText: '36'));

    expect(line().unitsBase, 72);
    expect(line().lineTotal, const Money(14400));
    expect(line().unitCost!.raw, 20000);
    expect(state().canSubmit, isTrue);
  });

  test('box: invalid price or box size blocks submit', () {
    draft().addProduct(snickers);
    box((f) => f.copyWith(priceText: '1.234'));
    expect(state().canSubmit, isFalse, reason: 'more than 2 decimals');

    box((f) => f.copyWith(priceText: '48', unitsPerBoxText: ''));
    expect(state().canSubmit, isFalse, reason: 'no box size');

    box((f) => f.copyWith(unitsPerBoxText: '0'));
    expect(state().canSubmit, isFalse);
    expect(line().ruleError, contains('unidades por caja'));
  });

  test('loose: unit price x quantity', () {
    draft().addProduct(gum);
    loose((f) => f.copyWith(unitPriceText: '1,25', units: 10));
    expect(line().unitsBase, 10);
    expect(line().lineTotal, const Money(1250));
  });

  test('loose by amount: the units come from the money spent', () {
    draft().addProduct(gum);
    loose((f) => f.copyWith(
          entry: LooseEntry.amount,
          unitPriceText: '0,50',
          amountText: '20',
        ));
    expect(line().unitsBase, 40);
    expect(state().canSubmit, isTrue);

    loose((f) => f.copyWith(amountText: '20,30'));
    expect(state().canSubmit, isFalse);
    expect(line().ruleError, contains('número exacto'));
  });

  test('loose: an expiry range that ends before it starts is rejected', () {
    draft().addProduct(gum);
    loose((f) => f.copyWith(
          unitPriceText: '1',
          expiryFrom: () => DateTime(2027, 3, 1),
          expiryTo: () => DateTime(2027, 2, 1),
        ));
    expect(state().canSubmit, isFalse);
    expect(line().ruleError, isNotNull);

    loose((f) => f.copyWith(expiryTo: () => null));
    expect(state().canSubmit, isTrue);
  });

  test('switching box <-> units starts a blank form', () {
    draft().addProduct(snickers);
    box((f) => f.copyWith(priceText: '50'));
    draft().setMode(line().id, Presentation.unit);
    expect(line().form, isA<LooseLotForm>());
    expect((line().form as LooseLotForm).unitPriceText, isEmpty);
    expect(state().canSubmit, isFalse);

    draft().setMode(line().id, Presentation.box);
    expect((line().form as BoxLotForm).priceText, isEmpty);
  });

  test('a form of the other mode is ignored', () {
    draft().addProduct(snickers);
    draft().updateForm(line().id, const LooseLotForm(unitPriceText: '1'));
    expect(line().form, isA<BoxLotForm>());
  });

  test('the total adds up the lines', () {
    draft()
      ..addProduct(snickers)
      ..addProduct(gum);
    box((f) => f.copyWith(boxes: 2, priceText: '48'));
    loose((f) => f.copyWith(unitPriceText: '1,25', units: 10), 1);
    expect(state().total, const Money(10850));
  });

  test('removeLine and clear', () {
    draft()
      ..addProduct(snickers)
      ..addProduct(gum);
    draft().removeLine(line().id);
    expect(line().product.name, 'Gum');
    draft().clear();
    expect(state().lines, isEmpty);
  });

  test('submit stores the lots, updates stock and empties the draft', () async {
    draft()
      ..addProduct(snickers)
      ..addProduct(snickers)
      ..setSupplier('  Distribuidora Sur ')
      ..setDate(DateTime(2026, 10, 1));
    box((f) => f.copyWith(
          boxes: 2,
          priceText: '48',
          expiry: () => DateTime(2027, 3, 15),
          lotCode: 'L-1',
        ));
    draft().setMode(line(1).id, Presentation.unit);
    loose((f) => f.copyWith(unitPriceText: '3', units: 6), 1);

    final purchase = await draft().submit();

    expect(purchase.total, const Money(11400));
    expect(purchase.supplier, 'Distribuidora Sur');
    expect(purchase.date, DateTime(2026, 10, 1));
    expect(purchase.lines[0].expiryTo, DateTime(2027, 3, 15));
    expect(purchase.lines[0].lotCode, 'L-1');
    final stored = (await container.read(productRepositoryProvider).getById(snickers.id))!;
    expect(stored.stockUnits, 54);
    // (48*2 + 6*3) / 54 = 2,1111
    expect(stored.avgCost.raw, 21111);
    expect(state().lines, isEmpty);
    expect(state().supplier, isEmpty);
  });

  test('a rejected submit keeps the draft', () async {
    draft().addProduct(snickers);
    box((f) => f.copyWith(priceText: '10'));
    await container.read(productRepositoryProvider).softDelete(snickers.id);

    await expectLater(draft().submit(), throwsA(isA<EntityNotFoundException>()));
    expect(state().lines, hasLength(1));
  });
}
