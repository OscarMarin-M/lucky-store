import '../../core/money/money.dart';
import '../../core/quantity/presentation.dart';
import '../sales/sale_draft.dart';
import 'date_format.dart';

/// The cart as a message for the customer, ready to paste in WhatsApp
/// (`*bold*`). Only what the customer pays shows up: no costs, no profit and
/// no charges the shop absorbs. Nothing is registered and stock is untouched.
///
/// ```
/// *Cotización · Lucky Store*
/// Caja San Valentín para Ana
/// 06/11/2026
///
/// • 3 × Snickers — Bs 5,00 c/u = Bs 15,00
/// • 1 caja de Twix (24 u) — Bs 100,00
/// • 1 × Reese's — de regalo 🎁
///
/// Adicionales:
/// • Armado — Bs 15,00
///
/// *Total: Bs 115,00*
/// Precios sujetos a disponibilidad.
/// ```
String quoteText(SaleDraftState draft, {required DateTime date}) {
  final out = StringBuffer('*Cotización · Lucky Store*\n');
  final name = draft.notes.trim();
  if (name.isNotEmpty) out.writeln(name);
  out
    ..writeln(formatDate(date))
    ..writeln();

  for (final l in draft.lines) {
    out.writeln('• ${_line(l)}');
  }

  final charges = draft.filledExtraCharges
      .where((c) => c.paidByCustomer && c.isValid)
      .toList();
  if (charges.isNotEmpty) {
    out
      ..writeln()
      ..writeln('Productos: ${draft.productsTotal.format()}')
      ..writeln('Adicionales:');
    for (final c in charges) {
      out.writeln('• ${c.concept.trim()} — ${c.amount!.format()}');
    }
  }

  out
    ..writeln()
    ..writeln('*Total: ${draft.total.format()}*')
    ..write('Precios sujetos a disponibilidad.');
  return out.toString();
}

/// `3 × Snickers — Bs 5,00 c/u = Bs 15,00`, `1 caja de Twix (24 u) — Bs 100,00`
String _line(DraftSaleLine l) {
  final q = l.quantity;
  final name = l.product.name;
  final isBox = l.presentation == Presentation.box;
  final what = isBox
      ? '$q ${q == 1 ? 'caja' : 'cajas'} de $name '
            '(${l.product.unitsPerBox} u${q == 1 ? '' : ' c/u'})'
      : '$q × $name';
  final price = l.unitPrice ?? Money.zero;
  if (price.isZero) return '$what — de regalo 🎁';
  if (q == 1) return '$what — ${price.format()}';
  final each = isBox ? 'c/caja' : 'c/u';
  return '$what — ${price.format()} $each = ${l.lineTotal!.format()}';
}
