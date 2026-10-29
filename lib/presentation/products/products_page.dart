import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
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

  List<Product> _filter(List<Product> all) {
    final q = _query.trim().toLowerCase();
    return all.where((p) {
      if (_dismissed.contains(p.id)) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          (p.sku?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);

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

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = product;
    final noStock = p.stockUnits <= 0;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final hasBoxes = p.unitsPerBox > 1;

    final subtitle = [
      if (p.sku != null) 'Cód. ${p.sku}',
      if (!p.isActive) 'Inactivo',
    ].join(' · ');

    // Left column = what the product is / how much there is; right column =
    // money. Each row pairs both sides on the same baseline.
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PairRow(
                left: Text(
                  p.name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                right: Text(
                  '${p.suggestedPriceUnit.format()} / u',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (subtitle.isNotEmpty || hasBoxes)
                _PairRow(
                  left: Text(subtitle, style: muted),
                  right: hasBoxes
                      ? Text(
                          '${p.suggestedPriceFor(Presentation.box).format()} / caja',
                          style: muted,
                        )
                      : const SizedBox.shrink(),
                ),
              const SizedBox(height: 10),
              _PairRow(
                left: Text(
                  noStock
                      ? 'Sin stock'
                      : hasBoxes && p.stockUnits >= p.unitsPerBox
                      ? '${formatStock(p.stockUnits, p.unitsPerBox)} · ${p.stockUnits} u'
                      : formatStock(p.stockUnits, p.unitsPerBox),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: noStock ? theme.colorScheme.loss : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                right: noStock
                    ? const SizedBox.shrink()
                    : Text('Costo ${p.avgCost.format()} / u', style: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `left ........ right` on a shared baseline; the left side yields space.
class _PairRow extends StatelessWidget {
  const _PairRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Expanded(child: left),
      const SizedBox(width: 12),
      right,
    ],
  );
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
