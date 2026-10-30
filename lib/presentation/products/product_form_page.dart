import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../domain/entities/product.dart';
import '../common/validators.dart';
import '../format/stock_format.dart';
import '../inventory/stock_write_off_page.dart';

/// Create or edit a product. Stock and cost are read-only here: they only
/// move through purchases, sales and adjustments.
class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _unitsPerBox;
  late final TextEditingController _priceUnit;
  late final TextEditingController _priceBox;
  late final TextEditingController _minStock;
  late bool _isActive;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name);
    _sku = TextEditingController(text: p?.sku);
    _unitsPerBox = TextEditingController(text: '${p?.unitsPerBox ?? 1}');
    _priceUnit = TextEditingController(
      text: p == null ? '' : p.suggestedPriceUnit.format(symbol: false),
    );
    _priceBox = TextEditingController(
      text: p?.suggestedPriceBox?.format(symbol: false) ?? '',
    );
    _minStock = TextEditingController(
      text: p?.minStockUnits == null ? '' : '${p!.minStockUnits}',
    );
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _unitsPerBox.dispose();
    _priceUnit.dispose();
    _priceBox.dispose();
    _minStock.dispose();
    super.dispose();
  }

  int get _unitsPerBoxValue => int.tryParse(_unitsPerBox.text.trim()) ?? 1;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repo = ref.read(productRepositoryProvider);
    final unitsPerBox = _unitsPerBoxValue;
    final sku = _sku.text.trim().isEmpty ? null : _sku.text.trim();
    final priceUnit = Money.parse(_priceUnit.text.trim());
    final priceBoxText = _priceBox.text.trim();
    // A box price only makes sense when the product has boxes.
    final priceBox = unitsPerBox > 1 && priceBoxText.isNotEmpty
        ? Money.parse(priceBoxText)
        : null;
    // Empty = no "stock bajo" alert for this product.
    final minStock = int.tryParse(_minStock.text.trim());

    try {
      final existing = widget.product;
      final Product saved;
      if (existing == null) {
        saved = await repo.create(
          Product.create(
            name: _name.text.trim(),
            sku: sku,
            unitsPerBox: unitsPerBox,
            suggestedPriceUnit: priceUnit,
            suggestedPriceBox: priceBox,
            minStockUnits: minStock,
          ),
        );
      } else {
        saved = await repo.update(
          existing.withDetails(
            name: _name.text.trim(),
            sku: sku,
            unitsPerBox: unitsPerBox,
            suggestedPriceUnit: priceUnit,
            suggestedPriceBox: priceBox,
            minStockUnits: minStock,
            isActive: _isActive,
          ),
        );
      }
      // Returned so callers (e.g. the purchase picker) can use the product.
      if (mounted) Navigator.of(context).pop(saved);
    } on DomainException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Live copy so the inventory card follows write-offs made from here.
    final original = widget.product;
    final p = original == null
        ? null
        : (ref
                  .watch(productsProvider)
                  .value
                  ?.where((x) => x.id == original.id)
                  .firstOrNull ??
              original);
    final hasBoxes = _unitsPerBoxValue > 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _sku,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Código (opcional)'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _unitsPerBox,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Unidades por caja',
                helperText: '1 si se vende solo por unidad',
              ),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                return (n == null || n < 1) ? 'Debe ser 1 o más' : null;
              },
            ),
            const SizedBox(height: 20),
            Text('Precio de venta sugerido', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceUnit,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Por unidad',
                      prefixText: 'Bs ',
                    ),
                    validator: (v) => validateMoney(v, required: true),
                  ),
                ),
                if (hasBoxes) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceBox,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Por caja',
                        prefixText: 'Bs ',
                      ),
                      validator: (v) => validateMoney(v, required: false),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hasBoxes
                  ? 'Puedes cambiarlo al vender. Sin precio por caja se usa unidad × cantidad. '
                        'El costo sale de las compras.'
                  : 'Puedes cambiarlo al vender. El costo sale de las compras.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _minStock,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Stock mínimo (opcional)',
                suffixText: 'u',
                helperText: 'Inicio avisa cuando quedan esas unidades o menos',
              ),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Producto activo'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inventario', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Stock: ${formatStock(p!.stockUnits, p.unitsPerBox)}'
                        '${p.stockUnits > 0 ? ' (${p.stockUnits} u)' : ''}',
                      ),
                      Text('Costo promedio: ${p.avgCost.format()} por unidad'),
                      Text('Valor en stock: ${p.stockValue.format()}'),
                      const SizedBox(height: 6),
                      Text(
                        'Se actualiza con compras, ventas y bajas.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StockWriteOffPage(product: p),
                          ),
                        ),
                        icon: const Icon(Icons.remove_circle_outline),
                        label: const Text('Dar de baja (merma, vencido…)'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_isEdit ? 'Guardar cambios' : 'Crear producto'),
          ),
        ),
      ),
    );
  }
}
