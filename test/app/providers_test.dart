import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/app/providers.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/domain/purchasing/purchase_lot.dart';
import 'package:lucky_store/domain/usecases/register_purchase.dart';
import 'package:lucky_store/domain/usecases/register_sale.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWith((ref) {
        final db = AppDatabase(NativeDatabase.memory());
        ref.onDispose(db.close);
        return db;
      }),
    ]);
  });

  tearDown(() => container.dispose());

  test('providers wire a full purchase -> sale flow on an in-memory database',
      () async {
    final products = container.read(productRepositoryProvider);
    final p = await products.create(Product.create(
      name: 'Snickers',
      unitsPerBox: 24,
      suggestedPriceUnit: const Money(300),
    ));

    await container.read(registerPurchaseProvider)(lines: [
      PurchaseLineInput(
        productId: p.id,
        lot: BoxLot(boxes: 1, unitsPerBox: 24, pricePerBox: const Money(4800)),
      ),
    ]);
    final sale = await container.read(registerSaleProvider)(lines: [
      SaleLineInput(
        productId: p.id,
        quantity: 10,
        presentation: Presentation.unit,
      ),
    ]);

    expect(sale.profit, const Money(1000)); // 30,00 - 10 x 2,00
    final profits =
        await container.read(saleRepositoryProvider).profitByProduct();
    expect(profits.single.productName, 'Snickers');
  });

  test('productsProvider streams the current products', () async {
    final sub = container.listen(productsProvider, (_, _) {});
    await container.read(productRepositoryProvider).create(
          Product.create(name: 'Twix'),
        );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(sub.read().value?.map((p) => p.name), ['Twix']);
  });
}
