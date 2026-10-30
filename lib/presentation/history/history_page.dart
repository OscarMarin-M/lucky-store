import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities/product.dart';
import '../format/date_format.dart';
import '../inventory/adjustment_labels.dart';
import '../theme/app_theme.dart';
import 'history_detail.dart';
import 'history_entry.dart';

/// "Historial" tab: every sale, purchase and write-off, newest first and
/// grouped by day, with what was sold and earned each day.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  HistoryFilter _filter = HistoryFilter.all;

  static const _filterLabels = {
    HistoryFilter.all: 'Todo',
    HistoryFilter.sales: 'Ventas',
    HistoryFilter.purchases: 'Compras',
    HistoryFilter.writeOffs: 'Bajas',
  };

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final byId = ref.watch(productsByIdProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                for (final f in HistoryFilter.values) ...[
                  ChoiceChip(
                    label: Text(_filterLabels[f]!),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            // A new document re-runs the provider: keep the old list on
            // screen instead of flashing a spinner.
            child: history.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('No se pudo cargar el historial\n$e')),
              data: (all) {
                final days = groupByDay(
                  all.where((e) => e.matches(_filter)).toList(),
                );
                if (days.isEmpty) return _EmptyState(filter: _filter);
                final now = DateTime.now();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: days.length,
                  itemBuilder: (_, i) => _DaySection(
                    day: days[i],
                    label: formatDayLabel(days[i].day, now),
                    byId: byId,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.label,
    required this.byId,
  });

  final HistoryDay day;
  final String label;
  final Map<String, Product> byId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final hasSales = day.entries.any((e) => e is SaleEntry);
    final profit = day.profit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: theme.textTheme.titleSmall),
              ),
              if (hasSales)
                Text.rich(
                  TextSpan(
                    text: 'Vendido ${day.salesTotal.format()} · ',
                    style: TextStyle(color: muted),
                    children: [
                      TextSpan(
                        text: 'ganancia ${profit.format()}',
                        style: TextStyle(
                          color: profit.isNegative
                              ? theme.colorScheme.loss
                              : theme.colorScheme.gain,
                        ),
                      ),
                    ],
                  ),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
        for (var i = 0; i < day.entries.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _EntryTile(entry: day.entries[i], byId: byId),
        ],
      ],
    );
  }
}

/// Each kind has its color so sales, purchases and write-offs are told apart
/// at a glance: green sale, blue purchase, red write-off.
Color _kindColor(ColorScheme scheme, HistoryEntry e) => switch (e) {
  SaleEntry() => scheme.gain,
  PurchaseEntry() => scheme.purchase,
  WriteOffEntry() => scheme.loss,
};

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.byId});

  final HistoryEntry entry;
  final Map<String, Product> byId;

  /// `Snickers, Twix +2`
  String _names(Iterable<String> productIds) {
    final names = productIds.toSet().map((id) => productName(byId, id)).toList();
    if (names.length <= 2) return names.join(', ');
    return '${names.take(2).join(', ')} +${names.length - 2}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final time = formatTime(entry.date);

    final (IconData icon, String title, String subtitle, Widget trailing,
        VoidCallback onTap) = switch (entry) {
      SaleEntry(:final sale) => (
          Icons.point_of_sale_outlined,
          sale.notes ?? _names(sale.lines.map((l) => l.productId)),
          [
            '$time · Venta',
            // A named order lists its products under the name.
            if (sale.notes != null) _names(sale.lines.map((l) => l.productId)),
            if (sale.extraCosts.isNotEmpty)
              '+ ${sale.extraCosts.length == 1 ? '1 costo adicional' : '${sale.extraCosts.length} costos adicionales'}',
          ].join(' · '),
          _Amounts(
            top: sale.total.format(),
            bottom: '${sale.profit.isNegative ? '' : '+'}${sale.profit.format()}',
            bottomColor: sale.profit.isNegative ? scheme.loss : scheme.gain,
          ),
          () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => SaleDetailPage(sale: sale),
              )),
        ),
      PurchaseEntry(:final purchase, :final firstExpiry) => (
          Icons.shopping_basket_outlined,
          _names(purchase.lines.map((l) => l.productId)),
          [
            '$time · Compra',
            if (purchase.supplier != null) purchase.supplier!,
            if (firstExpiry != null) 'vence ${formatDate(firstExpiry)}',
          ].join(' · '),
          _Amounts(top: purchase.total.format()),
          () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => PurchaseDetailPage(purchase: purchase),
              )),
        ),
      WriteOffEntry(:final adjustment) => (
          reasonIcon(adjustment.reason),
          productName(byId, adjustment.productId),
          '$time · Baja · ${reasonLabel(adjustment.reason)} · '
              '${adjustment.unitsBase} u',
          _Amounts(
            top: '-${adjustment.costTotal.format()}',
            topColor: scheme.loss,
          ),
          () => showWriteOffDetail(
                context,
                adjustment,
                productName(byId, adjustment.productId),
              ),
        ),
    };

    final kind = _kindColor(scheme, entry);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: Color.alphaBlend(
        kind.withValues(alpha: 0.10),
        scheme.surfaceContainerLow,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kind.withValues(alpha: 0.35)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: kind.withValues(alpha: 0.20),
          child: Icon(icon, color: kind),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: trailing,
      ),
    );
  }
}

/// Amount on the right of a tile, with the profit under a sale.
class _Amounts extends StatelessWidget {
  const _Amounts({
    required this.top,
    this.topColor,
    this.bottom,
    this.bottomColor,
  });

  final String top;
  final Color? topColor;
  final String? bottom;
  final Color? bottomColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(top, style: theme.textTheme.titleSmall?.copyWith(color: topColor)),
        if (bottom != null)
          Text(
            bottom!,
            style: theme.textTheme.bodySmall?.copyWith(color: bottomColor),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final HistoryFilter filter;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    final text = switch (filter) {
      HistoryFilter.all => 'Aquí aparecerán tus ventas, compras y bajas',
      HistoryFilter.sales => 'Todavía no hay ventas',
      HistoryFilter.purchases => 'Todavía no hay compras',
      HistoryFilter.writeOffs => 'Todavía no hay bajas',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 56, color: outline),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: outline)),
        ],
      ),
    );
  }
}
