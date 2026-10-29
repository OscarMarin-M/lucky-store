import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities/product.dart';
import '../format/stock_format.dart';
import '../products/product_form_page.dart';

/// Bottom sheet with a searchable list of active products. Returns the chosen
/// [Product] (or one created from the shortcut) through `Navigator.pop`.
Future<Product?> pickProduct(BuildContext context) {
  return showModalBottomSheet<Product>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const _ProductPickerSheet(),
  );
}

class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet();

  @override
  ConsumerState<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  String _query = '';

  Future<void> _createNew() async {
    final created = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (_) => const ProductFormPage()),
    );
    if (created != null && mounted) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final theme = Theme.of(context);
    final q = _query.trim().toLowerCase();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Buscar producto',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Crear producto nuevo'),
              onTap: _createNew,
            ),
            const Divider(height: 1),
            Expanded(
              child: products.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (all) {
                  final matches = all.where((p) {
                    if (!p.isActive) return false;
                    return q.isEmpty ||
                        p.name.toLowerCase().contains(q) ||
                        (p.sku?.toLowerCase().contains(q) ?? false);
                  }).toList();
                  if (matches.isEmpty) {
                    return const Center(child: Text('Sin resultados'));
                  }
                  return ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (_, i) {
                      final p = matches[i];
                      return ListTile(
                        title: Text(p.name),
                        subtitle: Text(
                          'Stock: ${formatStock(p.stockUnits, p.unitsPerBox)}'
                          '${p.unitsPerBox > 1 ? ' · ${p.unitsPerBox} u/caja' : ''}',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        onTap: () => Navigator.of(context).pop(p),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
