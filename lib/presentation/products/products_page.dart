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
      MaterialPageRoute<void>(builder: (_) => ProductFormPage(product: product)),
    );
  }

  Future<void> _delete(Product product) async {
    final repo = ref.read(productRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _dismissed.add(product.id));
    await repo.softDelete(product.id);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('"${product.name}" eliminado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () async {
            await repo.restore(product.id);
            if (mounted) setState(() => _dismissed.remove(product.id));
          },
        ),
      ));
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
        error: (e, _) => Center(child: Text('No se pudieron cargar los productos\n$e')),
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
                    hintText: 'Buscar por nombre o SKU',
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
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
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
                    if (p.sku != null)
                      Text(p.sku!, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                    const SizedBox(height: 6),
                    Text(
                      formatStock(p.stockUnits, p.unitsPerBox),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: noStock ? theme.colorScheme.loss : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (p.stockUnits > 0)
                      Text(
                        'Costo prom. ${p.avgCost.format()} · ${p.stockUnits} u',
                        style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    p.suggestedPriceUnit.format(),
                    style: theme.textTheme.titleMedium,
                  ),
                  Text('por unidad', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                  if (p.unitsPerBox > 1) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${p.suggestedPriceFor(Presentation.box).format()} / caja',
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                  if (!p.isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Inactivo', style: theme.textTheme.labelSmall?.copyWith(color: muted)),
                    ),
                ],
              ),
            ],
          ),
        ),
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
      child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onErrorContainer),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: color),
          const SizedBox(height: 12),
          const Text('Aún no tienes productos'),
          const SizedBox(height: 4),
          Text('Crea el primero para empezar a comprar y vender',
              style: TextStyle(color: color)),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onCreate, child: const Text('Crear producto')),
        ],
      ),
    );
  }
}
