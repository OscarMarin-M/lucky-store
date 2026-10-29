import 'package:flutter_test/flutter_test.dart';
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
}
