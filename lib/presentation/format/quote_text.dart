import '../../core/money/money.dart';
import '../sales/sale_draft.dart';
import 'date_format.dart';

/// The cart as a message for the customer, ready to paste in WhatsApp
/// (`*bold*`). Only what the customer pays shows up: no costs, no profit and
/// no charges the shop absorbs. Nothing is registered and stock is untouched.
///
/// ```
/// 🐻🍬 *Cotización · Lucky Store*
/// Caja San Valentín para Ana
/// 📅 06/11/2026
///
/// 🍬 3 × Snickers — Bs 5,00 c/u = Bs 15,00
/// 🍬 1 caja de Twix (24 u) — Bs 100,00
/// 🍬 1 × Reese's — de regalo 🎁
///
/// 🛍️ Productos: Bs 115,00
/// ✨ Adicionales:
/// • Armado — Bs 15,00
///
/// 💰 *Total: Bs 130,00*
/// Precios sujetos a disponibilidad.
/// ¡Gracias por elegir Lucky Store! 🐻💕
///
/// The emojis echo the logo (bear and candy); WhatsApp shows them on any
/// phone and they survive a plain copy.
/// ```
String quoteText(SaleDraftState draft, {required DateTime date}) {
  final out = StringBuffer('🐻🍬 *Cotización · Lucky Store*\n');
  final name = draft.notes.trim();
  if (name.isNotEmpty) out.writeln(name);
  out
    ..writeln('📅 ${formatDate(date)}')
    ..writeln();

  for (final l in draft.lines) {
    out.writeln('🍬 ${_line(l)}');
  }

  final charges = draft.filledExtraCharges
      .where((c) => c.paidByCustomer && c.isValid)
      .toList();
  if (charges.isNotEmpty) {
    out
      ..writeln()
      ..writeln('🛍️ Productos: ${draft.productsTotal.format()}')
      ..writeln('✨ Adicionales:');
    for (final c in charges) {
      out.writeln('• ${c.concept.trim()} — ${c.amount!.format()}');
    }
  }

  out
    ..writeln()
    ..writeln('💰 *Total: ${draft.total.format()}*')
    ..writeln('Precios sujetos a disponibilidad.')
    ..write('¡Gracias por elegir Lucky Store! 🐻💕');
  return out.toString();
}

/// `3 × Snickers — Bs 5,00 c/u = Bs 15,00`, `1 caja de Twix (24 u) — Bs 100,00`,
/// `2 bolsas de Skittles (30 u c/u) — Bs 25,00 c/bolsa = Bs 50,00`
String _line(DraftSaleLine l) {
  final q = l.quantity;
  final name = l.product.name;
  final pack = l.presentation;
  final what = pack.isPack
      ? '$q ${pack.nameFor(q)} de $name '
            '(${l.product.unitsIn(pack)} u${q == 1 ? '' : ' c/u'})'
      : '$q × $name';
  final price = l.unitPrice ?? Money.zero;
  if (price.isZero) return '$what — de regalo 🎁';
  if (q == 1) return '$what — ${price.format()}';
  final each = pack.eachSuffix;
  return '$what — ${price.format()} $each = ${l.lineTotal!.format()}';
}
