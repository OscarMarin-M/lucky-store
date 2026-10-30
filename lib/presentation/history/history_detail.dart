import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/money/money.dart';
import '../../core/quantity/presentation.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/stock_adjustment.dart';
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

class SaleDetailPage extends ConsumerWidget {
  const SaleDetailPage({super.key, required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(productsByIdProvider).value ?? const {};
    final theme = Theme.of(context);
    final cost = sale.lines.map((l) => l.costTotal).sum;
    final discount = sale.lines.map((l) => l.discount).sum;

    return Scaffold(
      appBar: AppBar(title: const Text('Venta')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            '${formatDate(sale.date)} · ${formatTime(sale.date)}',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          for (final l in sale.lines) ...[
            _SaleLineCard(line: l, name: productName(byId, l.productId)),
            const SizedBox(height: 10),
          ],
          _TotalsCard(rows: [
            ('Total cobrado', sale.total.format(), null),
            ('Costo', cost.format(), null),
            if (discount.cents > 0) ('Descuentos', discount.format(), null),
            (
              'Ganancia',
              sale.profit.format(),
              sale.profit.isNegative
                  ? theme.colorScheme.loss
                  : theme.colorScheme.gain,
            ),
          ]),
          if (sale.notes != null) ...[
            const SizedBox(height: 12),
            Text('Notas: ${sale.notes}'),
          ],
        ],
      ),
    );
  }
}

class _SaleLineCard extends StatelessWidget {
  const _SaleLineCard({required this.line, required this.name});

  final SaleLine line;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = line;
    final isGift = l.unitPrice == Money.zero;
    final qty = formatLineQuantity(
      quantity: l.quantity,
      isBox: l.presentation == Presentation.box,
      unitsBase: l.unitsBase,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            DetailRow(
              label: isGift ? '$qty · Regalo' : '$qty × ${l.unitPrice.format()}',
              value: l.lineTotal.format(),
              emphasis: true,
            ),
            if (l.discount.cents > 0 && !isGift)
              DetailRow(
                label: 'Descuento (sugerido ${l.suggestedUnitPrice.format()})',
                value: l.discount.format(),
              ),
            DetailRow(
              label: 'Costo (${l.costAtSale.format()} c/u)',
              value: l.costTotal.format(),
            ),
            DetailRow(
              label: 'Ganancia',
              value: l.profit.format(),
              color: l.profit.isNegative
                  ? theme.colorScheme.loss
                  : theme.colorScheme.gain,
            ),
          ],
        ),
      ),
    );
  }
}

class PurchaseDetailPage extends ConsumerWidget {
  const PurchaseDetailPage({super.key, required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(productsByIdProvider).value ?? const {};
    final theme = Theme.of(context);
    final p = purchase;

    return Scaffold(
      appBar: AppBar(title: const Text('Compra')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            [
              formatDate(p.date),
              formatTime(p.date),
              if (p.supplier != null) p.supplier!,
            ].join(' · '),
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          for (final l in p.lines) ...[
            _PurchaseLineCard(line: l, name: productName(byId, l.productId)),
            const SizedBox(height: 10),
          ],
          _TotalsCard(rows: [('Total pagado', p.total.format(), null)]),
          if (p.notes != null) ...[
            const SizedBox(height: 12),
            Text('Notas: ${p.notes}'),
          ],
        ],
      ),
    );
  }
}

class _PurchaseLineCard extends StatelessWidget {
  const _PurchaseLineCard({required this.line, required this.name});

  final PurchaseLine line;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = line;
    final isBox = l.presentation == Presentation.box;
    final qty = formatLineQuantity(
      quantity: l.quantity,
      isBox: isBox,
      unitsBase: l.unitsBase,
      unitsPerBox: l.unitsPerBox,
    );
    final price = _pricePerPresentation(l.lineTotal, l.quantity);
    final expiry = expiryText(l);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            DetailRow(
              label: '$qty × ${price.format()}',
              value: l.lineTotal.format(),
              emphasis: true,
            ),
            DetailRow(label: 'Sale a', value: '${l.unitCost.format()} c/u'),
            if (expiry != null || l.lotCode != null) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (expiry != null)
                    _Tag(icon: Icons.event_busy_outlined, text: expiry),
                  if (l.lotCode != null)
                    _Tag(icon: Icons.qr_code_2, text: 'Código ${l.lotCode}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
      final theme = Theme.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Baja · $name', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '${formatDate(a.date)} · ${formatTime(a.date)}',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              DetailRow(label: 'Motivo', value: reasonLabel(a.reason)),
              DetailRow(
                label: 'Cantidad',
                value: formatLineQuantity(
                  quantity: a.quantity,
                  isBox: a.presentation == Presentation.box,
                  unitsBase: a.unitsBase,
                ),
              ),
              DetailRow(label: 'Costo', value: '${a.unitCost.format()} c/u'),
              DetailRow(
                label: 'Pérdida',
                value: a.costTotal.format(),
                emphasis: true,
                color: theme.colorScheme.loss,
              ),
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
      padding: const EdgeInsets.only(bottom: 2),
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

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.rows});

  final List<(String, String, Color?)> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final (label, value, color) in rows)
              DetailRow(
                label: label,
                value: value,
                emphasis: true,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: muted)),
      ],
    );
  }
}
