import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/presentation/format/stock_format.dart';

void main() {
  group('formatStock', () {
    test('boxes and loose units', () {
      expect(formatStock(53, 24), '2 cajas + 5 u');
      expect(formatStock(24, 24), '1 caja');
      expect(formatStock(48, 24), '2 cajas');
      expect(formatStock(5, 24), '5 u');
    });

    test('products without boxes show units only', () {
      expect(formatStock(7, 1), '7 u');
    });

    test('empty and negative stock', () {
      expect(formatStock(0, 24), 'Sin stock');
      expect(formatStock(-3, 24), '-3 u');
    });
  });

  group('bags (v10)', () {
    test('stock in bags; loose units sold out of a bag break it', () {
      const bag = Presentation.bag;
      expect(formatStock(90, 30, pack: bag), '3 bolsas');
      expect(formatStock(85, 30, pack: bag), '2 bolsas + 25 u');
      expect(formatStock(30, 30, pack: bag), '1 bolsa');
      expect(formatStock(29, 30, pack: bag), '29 u');
    });

    test('a product shows its box, else its bag, else units', () {
      final loose = Product.create(name: 'Chicle');
      final bagged = Product.create(name: 'Skittles', unitsPerBag: 30);
      final both = Product.create(name: 'Twix', unitsPerBox: 24, unitsPerBag: 10);
      expect(formatProductStock(loose, units: 40), '40 u');
      expect(formatProductStock(bagged, units: 65), '2 bolsas + 5 u');
      expect(formatProductStock(both, units: 50), '2 cajas + 2 u');
    });

    test('document lines name the pack', () {
      expect(
        formatLineQuantity(
          quantity: 2,
          presentation: Presentation.bag,
          unitsBase: 50,
          packSize: 25,
        ),
        '2 bolsas de 25 u',
      );
      expect(
        formatLineQuantity(quantity: 1, presentation: Presentation.bag, unitsBase: 30),
        '1 bolsa de 30 u',
      );
    });
  });
}
