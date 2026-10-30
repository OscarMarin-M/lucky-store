import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/money/money.dart';
import '../../core/quantity/presentation.dart';
import '../../domain/entities/product.dart';
import '../format/stock_format.dart';
import '../theme/app_theme.dart';
import 'product_form_page.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  String _query = '';

  /// Ids swiped away. A Dismissible must leave the tree in the same frame,
  /// but the database stream emits a moment later, so we hide them locally.
  final Set<String> _dismissed = {};

  Future<void> _openForm([Product? product]) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductFormPage(product: product),
      ),
    );
  }

  Future<void> _delete(Product product) async {
    final repo = ref.read(productRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _dismissed.add(product.id));
    await repo.softDelete(product.id);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${product.name}" eliminado'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () async {
              await repo.restore(product.id);
              if (mounted) setState(() => _dismissed.remove(product.id));
            },
          ),
        ),
      );
  }

  _StockFilter _stockFilter = _StockFilter.all;

  List<Product> _filter(List<Product> all) {
    final q = _query.trim().toLowerCase();
    return all.where((p) {
      if (_dismissed.contains(p.id)) return false;
      if (!_stockFilter.accepts(p)) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          (p.sku?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('No se pudieron cargar los productos\n$e')),
        data: (all) {
          if (all.isEmpty) return _EmptyState(onCreate: _openForm);
          final visible = _filter(all);
          final shown = all.where((p) => !_dismissed.contains(p.id));
          final value = shown
              .where((p) => p.stockUnits > 0)
              .map((p) => p.stockValue)
              .fold(Money.zero, (a, b) => a + b);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o código',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final f in _StockFilter.values) ...[
                      ChoiceChip(
                        label: Text(
                          '${f.label} (${shown.where(f.accepts).length})',
                        ),
                        selected: _stockFilter == f,
                        onSelected: (_) => setState(() => _stockFilter = f),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Text(
                      '${visible.length} de ${shown.length} productos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'En stock: ${value.format()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('Sin resultados'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final p = visible[i];
                          return Dismissible(
                            key: ValueKey(p.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _delete(p),
                            background: const _DeleteBackground(),
                            child: _ProductCard(
                              product: p,
                              onTap: () => _openForm(p),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Quick filters over the catalog; each counts its products in the chip.
enum _StockFilter {
  all('Todos'),
  inStock('Con stock'),
  low('Stock bajo'),
  out('Sin stock');

  const _StockFilter(this.label);
  final String label;

  bool accepts(Product p) => switch (this) {
    _StockFilter.all => true,
    _StockFilter.inStock => p.stockUnits > 0,
    _StockFilter.low => p.isLowStock,
    _StockFilter.out => p.stockUnits <= 0,
  };
}

/// Catalog card: name and prices on top; below, the three figures the owner
/// checks most: how much there is, what it cost and what each unit leaves.
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = product;
    final noStock = p.stockUnits <= 0;
    final hasBoxes = p.unitsPerBox > 1;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    // What one unit leaves at the suggested price; only once there is a cost.
    final hasCost = p.avgCost.raw > 0;
    final unitProfit = p.suggestedPriceUnit - p.avgCost.totalFor(1);
    final margin = p.suggestedPriceUnit.cents == 0
        ? null
        : unitProfit.cents * 100 / p.suggestedPriceUnit.cents;

    final (Color statusColor, String? status) = !p.isActive
        ? (scheme.outline, 'Inactivo')
        : noStock
        ? (scheme.loss, 'Sin stock')
        : p.isLowStock
        ? (scheme.tertiary, 'Stock bajo')
        : (scheme.gain, null);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Initials(name: p.name, color: statusColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (status != null)
                              _Pill(text: status, color: statusColor),
                            if (hasBoxes)
                              Text('Caja de ${p.unitsPerBox} u', style: muted),
                            if (p.sku != null)
                              Text('Cód. ${p.sku}', style: muted),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${p.suggestedPriceUnit.format()} / u',
                        style: theme.textTheme.titleSmall,
                      ),
                      if (hasBoxes)
                        Text(
                          '${p.suggestedPriceFor(Presentation.box).format()} / caja',
                          style: muted,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _Figure(
                      label: 'Stock',
                      // The pill already says "Sin stock".
                      value: noStock
                          ? '${p.stockUnits} u'
                          : formatStock(p.stockUnits, p.unitsPerBox),
                      detail: hasBoxes && p.stockUnits >= p.unitsPerBox
                          ? '${p.stockUnits} u'
                          : null,
                      color: noStock ? scheme.loss : null,
                    ),
                    _Figure(
                      label: 'Costo',
                      value: hasCost ? p.avgCost.format() : '—',
                      detail: hasCost ? 'por unidad' : 'sin compras',
                    ),
                    _Figure(
                      label: 'Ganas c/u',
                      value: hasCost ? unitProfit.format() : '—',
                      detail: hasCost && margin != null
                          ? '${margin.toStringAsFixed(0)}% margen'
                          : null,
                      color: hasCost
                          ? (unitProfit.isNegative ? scheme.loss : scheme.gain)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round badge with the product's initials, tinted by its stock status.
class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final initials = words.take(2).map((w) => w[0].toUpperCase()).join();
    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withValues(alpha: 0.18),
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// One of the three columns at the bottom of a product card.
class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    this.detail,
    this.color,
  });

  final String label;
  final String value;
  final String? detail;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: muted)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (detail != null)
            Text(
              detail!,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: color),
          const SizedBox(height: 12),
          const Text('Aún no tienes productos'),
          const SizedBox(height: 4),
          Text(
            'Crea el primero para empezar a comprar y vender',
            style: TextStyle(color: color),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onCreate,
            child: const Text('Crear producto'),
          ),
        ],
      ),
    );
  }
}
