import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/money/money.dart';
import '../../core/quantity/presentation.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../common/section_title.dart';
import '../format/date_format.dart';
import '../format/stock_format.dart';
import '../inventory/adjustment_labels.dart';
import '../theme/app_theme.dart';

/// Name of [id], also for products deleted after the document was made.
String productName(Map<String, Product> byId, String id) =>
    byId[id]?.name ?? 'Producto eliminado';

/// What the owner sees about a lot's expiry: one date for a box, a range for
/// loose units. Null when no date was recorded.
String? expiryText(PurchaseLine l) {
  final from = l.expiryFrom, to = l.expiryTo;
  if (from == null && to == null) return null;
  if (from == null || to == null || from == to) {
    return 'Vence ${formatDate((from ?? to)!)}';
  }
  return 'Vence entre ${formatDate(from)} y ${formatDate(to)}';
}

/// Price per box or per unit of a purchase line, as it was typed.
Money _pricePerPresentation(Money total, int quantity) =>
    Money(quantity == 0 ? 0 : total.cents ~/ quantity);

Color _profitColor(ColorScheme s, Money m) => m.isNegative ? s.loss : s.gain;

// --- Sale -----------------------------------------------------------------

class SaleDetailPage extends ConsumerWidget {
  const SaleDetailPage({super.key, required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(productsByIdProvider).value ?? const {};
    final scheme = Theme.of(context).colorScheme;
    final cost = sale.lines.map((l) => l.costTotal).sum;
    final discount = sale.lines.map((l) => l.discount).sum;
    final hasCharges = sale.extraCharges.isNotEmpty;
    final margin = sale.total.cents == 0
        ? null
        : sale.profit.cents * 100 / sale.total.cents;

    return Scaffold(
      // The note names the order ("Caja San Valentín para Ana").
      appBar: AppBar(title: Text(sale.notes ?? 'Venta')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _HeroCard(
            color: scheme.gain,
            icon: Icons.point_of_sale_outlined,
            kind: 'Venta',
            amount: sale.total,
            when: sale.date,
            pill: 'Ganancia ${sale.profit.format()}',
            pillColor: _profitColor(scheme, sale.profit),
          ),
          const SectionTitle('Productos', icon: Icons.shopping_bag_outlined),
          _LinesCard(children: [
            for (final l in sale.lines)
              _SaleLineTile(line: l, name: productName(byId, l.productId)),
          ]),
          if (hasCharges) ...[
            SectionTitle(
              'Cargos adicionales',
              icon: Icons.add_card_outlined,
              color: scheme.gain,
            ),
            _LinesCard(children: [
              for (final c in sale.extraCharges)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: DetailRow(
                    label: c.concept,
                    value: '+${c.amount.format()}',
                    color: scheme.gain,
                  ),
                ),
            ]),
          ],
          const SectionTitle('Resumen', icon: Icons.receipt_long_outlined),
          _SummaryCard(groups: [
            [
              if (hasCharges) ...[
                ('Productos', sale.linesTotal.format(), null),
                ('Cargos adicionales', sale.extraChargesTotal.format(), null),
              ],
              ('Total cobrado', sale.total.format(), null),
            ],
            [
              ('Costo de productos', cost.format(), null),
              if (discount.cents > 0) ('Descuentos', discount.format(), null),
            ],
            [
              ('Ganancia', sale.profit.format(), _profitColor(scheme, sale.profit)),
              if (margin != null)
                ('Margen', '${margin.toStringAsFixed(0)}%', null),
            ],
          ]),
        ],
      ),
    );
  }
}

class _SaleLineTile extends StatelessWidget {
  const _SaleLineTile({required this.line, required this.name});

  final SaleLine line;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final l = line;
    final isGift = l.unitPrice == Money.zero;
    final qty = formatLineQuantity(
      quantity: l.quantity,
      isBox: l.presentation == Presentation.box,
      unitsBase: l.unitsBase,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailRow(label: name, value: l.lineTotal.format(), emphasis: true),
          const SizedBox(height: 2),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                isGift ? '$qty · Regalo' : '$qty × ${l.unitPrice.format()}',
                style: muted,
              ),
              if (isGift)
                _Chip(
                  icon: Icons.card_giftcard,
                  text: 'Regalo',
                  color: scheme.tertiary,
                ),
              if (l.discount.cents > 0 && !isGift)
                _Chip(
                  icon: Icons.sell_outlined,
                  text: '-${l.discount.format()} '
                      '(sugerido ${l.suggestedUnitPrice.format()})',
                  color: scheme.tertiary,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Costo ${l.costAtSale.format()} c/u · ${l.costTotal.format()}',
                  style: muted,
                ),
              ),
              Text(
                'Ganancia ${l.profit.format()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _profitColor(scheme, l.profit),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Purchase -------------------------------------------------------------

class PurchaseDetailPage extends ConsumerWidget {
  const PurchaseDetailPage({super.key, required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(productsByIdProvider).value ?? const {};
    final scheme = Theme.of(context).colorScheme;
    final p = purchase;
    final units = p.lines.map((l) => l.unitsBase).fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Compra')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _HeroCard(
            color: scheme.purchase,
            icon: Icons.shopping_basket_outlined,
            kind: 'Compra',
            amount: p.total,
            when: p.date,
            pill: p.supplier,
            pillIcon: Icons.storefront_outlined,
            pillColor: scheme.purchase,
          ),
          SectionTitle(
            p.lines.length == 1 ? 'Lote' : 'Lotes (${p.lines.length})',
            icon: Icons.inventory_2_outlined,
            color: scheme.purchase,
          ),
          _LinesCard(children: [
            for (final l in p.lines)
              _PurchaseLineTile(line: l, name: productName(byId, l.productId)),
          ]),
          const SectionTitle('Resumen', icon: Icons.receipt_long_outlined),
          _SummaryCard(groups: [
            [
              ('Unidades que entraron', '$units u', null),
              ('Total pagado', p.total.format(), null),
            ],
          ]),
          if (p.notes != null) ...[
            const SizedBox(height: 12),
            Text('Notas: ${p.notes}'),
          ],
        ],
      ),
    );
  }
}

class _PurchaseLineTile extends StatelessWidget {
  const _PurchaseLineTile({required this.line, required this.name});

  final PurchaseLine line;
  final String name;

  /// Red if expired, warning tone within 30 days, neutral otherwise.
  static Color _expiryColor(ColorScheme scheme, DateTime? d) {
    if (d == null) return scheme.onSurfaceVariant;
    final now = DateTime.now();
    final days = d.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (days < 0) return scheme.loss;
    if (days <= 30) return scheme.tertiary;
    return scheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final l = line;
    final qty = formatLineQuantity(
      quantity: l.quantity,
      isBox: l.presentation == Presentation.box,
      unitsBase: l.unitsBase,
      unitsPerBox: l.unitsPerBox,
    );
    final price = _pricePerPresentation(l.lineTotal, l.quantity);
    final expiry = expiryText(l);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailRow(label: name, value: l.lineTotal.format(), emphasis: true),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(child: Text('$qty × ${price.format()}', style: muted)),
              Text('Sale a ', style: muted),
              Text(
                '${l.unitCost.format()} c/u',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (expiry != null || l.lotCode != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (expiry != null)
                  _Chip(
                    icon: Icons.event_busy_outlined,
                    text: expiry,
                    color: _expiryColor(scheme, l.expiryFrom),
                  ),
                if (l.lotCode != null)
                  _Chip(
                    icon: Icons.qr_code_2,
                    text: 'Código ${l.lotCode}',
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// --- Write-off ------------------------------------------------------------

/// Write-offs are a single line: a sheet is enough.
Future<void> showWriteOffDetail(
  BuildContext context,
  StockAdjustment a,
  String name,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroCard(
                color: scheme.loss,
                icon: reasonIcon(a.reason),
                kind: 'Baja · $name',
                amount: a.costTotal,
                amountPrefix: '-',
                when: a.date,
                pill: reasonLabel(a.reason),
                pillColor: scheme.loss,
              ),
              const SizedBox(height: 12),
              _SummaryCard(groups: [
                [
                  (
                    'Cantidad',
                    formatLineQuantity(
                      quantity: a.quantity,
                      isBox: a.presentation == Presentation.box,
                      unitsBase: a.unitsBase,
                    ),
                    null,
                  ),
                  ('Costo', '${a.unitCost.format()} c/u', null),
                  ('Pérdida', a.costTotal.format(), scheme.loss),
                ],
              ]),
              if (a.notes != null) ...[
                const SizedBox(height: 8),
                Text('Notas: ${a.notes}'),
              ],
            ],
          ),
        ),
      );
    },
  );
}

// --- Building blocks ------------------------------------------------------

/// Top of a detail: the kind in its color, the amount big, when it happened
/// and one highlighted fact (profit of a sale, supplier of a purchase...).
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.color,
    required this.icon,
    required this.kind,
    required this.amount,
    required this.when,
    this.amountPrefix = '',
    this.pill,
    this.pillIcon,
    this.pillColor,
  });

  final Color color;
  final IconData icon;
  final String kind;
  final Money amount;
  final String amountPrefix;
  final DateTime when;
  final String? pill;
  final IconData? pillIcon;
  final Color? pillColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: Color.alphaBlend(
        color.withValues(alpha: 0.12),
        scheme.surfaceContainerLow,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withValues(alpha: 0.22),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    kind,
                    style: theme.textTheme.titleSmall?.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '$amountPrefix${amount.format()}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${formatDayLabel(when, DateTime.now())} · ${formatTime(when)}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            if (pill != null) ...[
              const SizedBox(height: 12),
              _Chip(
                icon: pillIcon,
                text: pill!,
                color: pillColor ?? color,
                large: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lines of a document in one card, separated by thin rules.
class _LinesCard extends StatelessWidget {
  const _LinesCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
          children[i],
        ],
      ],
    ),
  );
}

/// Totals in groups separated by rules; the last row of a group is bold.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.groups});

  final List<List<(String, String, Color?)>> groups;

  @override
  Widget build(BuildContext context) {
    final filled = groups.where((g) => g.isNotEmpty).toList();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            for (var g = 0; g < filled.length; g++) ...[
              if (g > 0) const Divider(height: 20),
              for (var i = 0; i < filled[g].length; i++)
                DetailRow(
                  label: filled[g][i].$1,
                  value: filled[g][i].$2,
                  color: filled[g][i].$3,
                  emphasis: i == filled[g].length - 1,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// `label ............ value`
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasis = false,
    this.color,
  });

  final String label;
  final String value;
  final bool emphasis;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = emphasis
        ? theme.textTheme.titleSmall
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: base)),
          const SizedBox(width: 12),
          Text(value, style: base?.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Small tinted label: gift, discount, expiry, code, supplier...
class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.color,
    this.icon,
    this.large = false,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final style = (large
            ? Theme.of(context).textTheme.labelLarge
            : Theme.of(context).textTheme.labelMedium)
        ?.copyWith(color: color, fontWeight: FontWeight.w600);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: large ? 16 : 14, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
