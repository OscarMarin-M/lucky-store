import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/money/money.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/domain/entities/product.dart';
import 'package:lucky_store/presentation/format/quote_text.dart';
import 'package:lucky_store/presentation/sales/sale_draft.dart';

void main() {
  final snickers = Product.create(
    name: 'Snickers',
    suggestedPriceUnit: const Money(500),
  );
  final twix = Product.create(name: 'Twix', unitsPerBox: 24);
  final reeses = Product.create(name: "Reese's");
  final date = DateTime(2026, 11, 6);

  DraftSaleLine line(
    Product p,
    int q,
    String price, [
    Presentation pr = Presentation.unit,
  ]) => DraftSaleLine(
    id: p.name,
    product: p,
    quantity: q,
    presentation: pr,
    priceText: price,
  );

  test('lists products, customer charges and the total; hides shop costs', () {
    final draft = SaleDraftState(
      notes: ' Caja San Valentín para Ana ',
      lines: [
        line(snickers, 3, '5,00'),
        line(twix, 1, '100', Presentation.box),
        line(twix, 2, '90', Presentation.box),
        line(reeses, 1, '0'),
      ],
      extraCharges: const [
        DraftExtraCharge(
          id: 'a',
          concept: 'Armado',
          amountText: '15',
          paidByCustomer: true,
        ),
        DraftExtraCharge(id: 'b', concept: 'Impresión', amountText: '4'),
        DraftExtraCharge(id: 'c'), // blank row
      ],
    );

    expect(quoteText(draft, date: date), '''
🐻🍬 *Cotización · Lucky Store*
Caja San Valentín para Ana
📅 06/11/2026

🍬 3 × Snickers — Bs 5,00 c/u = Bs 15,00
🍬 1 caja de Twix (24 u) — Bs 100,00
🍬 2 cajas de Twix (24 u c/u) — Bs 90,00 c/caja = Bs 180,00
🍬 1 × Reese's — de regalo 🎁

🛍️ Productos: Bs 295,00
✨ Adicionales:
• Armado — Bs 15,00

💰 *Total: Bs 310,00*
Precios sujetos a disponibilidad.
¡Gracias por elegir Lucky Store! 🐻💕''');
  });

  test('without a name or customer charges it is just products and total', () {
    final draft = SaleDraftState(
      lines: [line(snickers, 1, '5')],
      extraCharges: const [
        DraftExtraCharge(id: 'b', concept: 'Empaque', amountText: '2'),
      ],
    );
    final text = quoteText(draft, date: date);
    expect(text, isNot(contains('Empaque')));
    expect(text, isNot(contains('Adicionales')));
    expect(
      text,
      contains('📅 06/11/2026\n\n🍬 1 × Snickers — Bs 5,00\n\n💰 *Total: Bs 5,00*'),
    );
  });

  test('a quote ignores stock but needs valid prices', () {
    final noStock = SaleDraftState(lines: [line(snickers, 50, '5')]);
    expect(noStock.canSubmit(allowNegativeStock: false), isFalse);
    expect(noStock.canQuote, isTrue);
    expect(SaleDraftState(lines: [line(snickers, 1, 'abc')]).canQuote, isFalse);
    expect(const SaleDraftState().canQuote, isFalse);
  });

  test('a bag line names the bag and its units (v10)', () {
    final skittles = Product.create(name: 'Skittles', unitsPerBag: 30);
    final text = quoteText(
      SaleDraftState(lines: [line(skittles, 2, '25', Presentation.bag)]),
      date: date,
    );
    expect(
      text,
      contains('2 bolsas de Skittles (30 u c/u) — Bs 25,00 c/bolsa = Bs 50,00'),
    );
  });
}
