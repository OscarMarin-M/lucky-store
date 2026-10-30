import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money.dart';
import '../../domain/reports/dashboard_reports.dart';
import '../format/date_format.dart';
import '../format/stock_format.dart';
import '../theme/app_theme.dart';
import 'dashboard.dart';

/// "Inicio" tab: how the shop is doing in a period (sales, real profit,
/// purchases, losses), profit per product, and what needs attention now
/// (lots about to expire, low stock).
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  HomePeriod _period = HomePeriod.today;

  static const _labels = {
    HomePeriod.today: 'Hoy',
    HomePeriod.week: '7 días',
    HomePeriod.month: 'Este mes',
    HomePeriod.all: 'Todo',
  };

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider(_period));

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SegmentedButton<HomePeriod>(
              showSelectedIcon: false,
              segments: [
                for (final p in HomePeriod.values)
                  ButtonSegment(value: p, label: Text(_labels[p]!)),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
          ),
          Expanded(
            child: dashboard.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('No se pudo cargar el resumen\n$e')),
              data: (d) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  _SummaryGrid(summary: d.summary),
                  if (d.hasAlerts) ...[
                    _SectionTitle(
                      'Atención',
                      icon: Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    _AlertsCard(dashboard: d),
                  ],
                  const _SectionTitle(
                    'Ganancia por producto',
                    icon: Icons.leaderboard_outlined,
                  ),
                  _ResultsCard(
                    results: d.results,
                    extraCharges: d.summary.extraCharges,
                  ),
                  const _SectionTitle(
                    'Inventario',
                    icon: Icons.inventory_2_outlined,
                  ),
                  _InventoryCard(dashboard: d),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header that stands out from the cards: icon, larger bold text in
/// the accent color and a rule to the edge.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.icon, this.color});

  final String text;
  final IconData icon;

  /// Defaults to the theme accent; "Atención" uses a warning tone.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 28, 2, 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: c),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: c,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: c.withValues(alpha: 0.35))),
        ],
      ),
    );
  }
}

Color _profitColor(ColorScheme scheme, Money m) =>
    m.isNegative ? scheme.loss : scheme.gain;

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = summary;
    final count = s.salesCount == 1 ? '1 venta' : '${s.salesCount} ventas';
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Ventas',
                value: s.salesTotal.format(),
                detail: count,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Ganancia',
                value: s.netProfit.format(),
                valueColor: _profitColor(scheme, s.netProfit),
                detail: switch ((s.writeOffLoss.cents > 0, s.extraCharges.cents > 0)) {
                  (true, true) => 'con cargos extra, menos bajas',
                  (true, false) => 'ya restadas las bajas',
                  (false, true) => 'incluye cargos adicionales',
                  (false, false) => 'de lo vendido',
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Compras',
                value: s.purchasesTotal.format(),
                detail: 'mercadería que entró',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Pérdidas por bajas',
                value: s.writeOffLoss.format(),
                valueColor: s.writeOffLoss.cents > 0 ? scheme.loss : null,
                detail: 'merma, vencidos, otros',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.detail,
    this.valueColor,
  });

  final String label;
  final String value;
  final String detail;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: muted)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(color: valueColor),
              ),
            ),
            Text(detail, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
          ],
        ),
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({required this.dashboard});

  final Dashboard dashboard;

  /// `vence en 12 días`, `vence hoy`, `venció hace 2 días`
  static String _when(ExpiryAlert a) {
    final n = a.daysLeft;
    if (n == 0) return 'vence hoy';
    if (n == 1) return 'vence mañana';
    if (n > 1) return 'vence en $n días';
    return n == -1 ? 'venció ayer' : 'venció hace ${-n} días';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tiles = <Widget>[
      for (final a in dashboard.expiring)
        ListTile(
          leading: Icon(
            Icons.event_busy_outlined,
            color: a.isExpired ? scheme.loss : scheme.tertiary,
          ),
          title: Text(a.product.name),
          subtitle: Text(
            'Un lote ${_when(a)} (${formatDate(a.expiry)}) · '
            'tienes ${a.unitsLeft} u de ese lote',
          ),
        ),
      for (final p in dashboard.lowStock)
        ListTile(
          leading: Icon(Icons.trending_down, color: scheme.tertiary),
          title: Text(p.name),
          subtitle: Text(
            'Stock bajo: ${formatStock(p.stockUnits, p.unitsPerBox)} '
            '(mínimo ${p.minStockUnits} u)',
          ),
        ),
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 56),
            tiles[i],
          ],
        ],
      ),
    );
  }
}

/// Best products first; the rest behind "Ver todos" so the screen stays short.
class _ResultsCard extends StatefulWidget {
  const _ResultsCard({required this.results, required this.extraCharges});

  final List<ProductResult> results;

  /// Charges of the orders that belong to no product: a last row so the
  /// list adds up to the profit card.
  final Money extraCharges;

  @override
  State<_ResultsCard> createState() => _ResultsCardState();
}

class _ResultsCardState extends State<_ResultsCard> {
  static const _collapsed = 5;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final all = widget.results;
    if (all.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Sin ventas en este período',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }
    final visible = _expanded ? all : all.take(_collapsed).toList();
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _ResultTile(result: visible[i]),
          ],
          if (all.length > _collapsed)
            TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(_expanded ? 'Ver menos' : 'Ver todos (${all.length})'),
            ),
          if (widget.extraCharges.cents > 0) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Cargos adicionales de pedidos'),
              subtitle: const Text('armado, empaque, impresión…'),
              trailing: Text(
                '+${widget.extraCharges.format()}',
                style: theme.textTheme.titleSmall?.copyWith(color: scheme.gain),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result});

  final ProductResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final r = result;
    final margin = r.marginPercent;
    return ListTile(
      title: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (r.unitsSold > 0) '${r.unitsSold} u · ${r.revenue.format()}',
          if (r.writeOffLoss.cents > 0) 'bajas -${r.writeOffLoss.format()}',
        ].join(' · '),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            r.netProfit.format(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: _profitColor(scheme, r.netProfit),
            ),
          ),
          if (margin != null)
            Text(
              '${margin.toStringAsFixed(0)}% margen',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.dashboard});

  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = dashboard.productsInStock;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: Text(
          'Valor en stock: ${dashboard.inventoryValue.format()}',
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          '${n == 1 ? '1 producto' : '$n productos'} con stock · a costo promedio',
        ),
      ),
    );
  }
}
