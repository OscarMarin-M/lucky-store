import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/domain_exception.dart';
import '../../core/quantity/presentation.dart';
import '../common/quantity_stepper.dart';
import '../common/validators.dart';
import '../format/date_format.dart';
import 'product_picker_sheet.dart';
import 'purchase_draft.dart';

/// "Comprar" tab: build a purchase line by line and register it.
class PurchasePage extends ConsumerStatefulWidget {
  const PurchasePage({super.key});

  @override
  ConsumerState<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends ConsumerState<PurchasePage> {
  final _supplier = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _supplier.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    final product = await pickProduct(context);
    if (product != null) {
      ref.read(purchaseDraftProvider.notifier).addProduct(product);
    }
  }

  Future<void> _pickDate() async {
    final draft = ref.read(purchaseDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(purchaseDraftProvider.notifier).setDate(picked);
    }
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final total = ref.read(purchaseDraftProvider).total;
    setState(() => _submitting = true);
    try {
      await ref.read(purchaseDraftProvider.notifier).submit();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Compra registrada · ${total.format()}')),
        );
    } on DomainException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(purchaseDraftProvider);
    final notifier = ref.read(purchaseDraftProvider.notifier);
    final theme = Theme.of(context);

    // Keep the field in step when the draft is cleared after registering.
    ref.listen(purchaseDraftProvider, (_, next) {
      if (next.supplier != _supplier.text) _supplier.text = next.supplier;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprar'),
        actions: [
          if (draft.lines.isNotEmpty)
            TextButton(onPressed: notifier.clear, child: const Text('Vaciar')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.event, size: 18),
                label: Text(
                  draft.date == null ? 'Hoy' : formatDate(draft.date!),
                ),
                onPressed: _pickDate,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _supplier,
            onChanged: notifier.setSupplier,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Proveedor (opcional)',
            ),
          ),
          const SizedBox(height: 16),
          for (final line in draft.lines) ...[
            _LineCard(key: ValueKey(line.id), line: line),
            const SizedBox(height: 10),
          ],
          if (draft.lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: 56,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Agrega los productos que compraste',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text('Agregar producto'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: theme.textTheme.titleMedium),
                  Text(draft.total.format(), style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: draft.canSubmit && !_submitting ? _submit : null,
                child: const Text('Registrar compra'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineCard extends ConsumerStatefulWidget {
  const _LineCard({super.key, required this.line});

  final DraftPurchaseLine line;

  @override
  ConsumerState<_LineCard> createState() => _LineCardState();
}

class _LineCardState extends ConsumerState<_LineCard> {
  late final TextEditingController _qty;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _qty = TextEditingController(text: '${widget.line.quantity}');
    _price = TextEditingController(text: widget.line.priceText);
  }

  /// Switching box/unit clears the price in the draft: mirror it.
  @override
  void didUpdateWidget(covariant _LineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.line.priceText != _price.text) {
      _price.text = widget.line.priceText;
    }
  }

  @override
  void dispose() {
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final product = line.product;
    final notifier = ref.read(purchaseDraftProvider.notifier);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final isBox = line.presentation == Presentation.box;

    final units = line.unitsBase;
    final total = line.lineTotal;
    final unitCost = line.unitCost;
    String? averagePreview;
    if (units != null && total != null && unitCost != null) {
      final next = ref
          .read(costStrategyProvider)
          .applyPurchase(product.stockState, units: units, total: total);
      averagePreview = product.stockUnits > 0
          ? 'Costo promedio pasa de ${product.avgCost.format()} a ${next.avgCost.format()}'
          : 'Costo promedio: ${next.avgCost.format()}';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(product.name, style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: 'Quitar',
                  icon: const Icon(Icons.close),
                  onPressed: () => notifier.removeLine(line.id),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  if (product.unitsPerBox > 1) ...[
                    SegmentedButton<Presentation>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: Presentation.box,
                          label: Text('Caja (${product.unitsPerBox} u)'),
                        ),
                        const ButtonSegment(
                          value: Presentation.unit,
                          label: Text('Unidad'),
                        ),
                      ],
                      selected: {line.presentation},
                      onSelectionChanged: (s) =>
                          notifier.setPresentation(line.id, s.first),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QuantityStepper(
                        controller: _qty,
                        onChanged: (q) => notifier.setQuantity(line.id, q),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _price,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (v) => notifier.setPrice(line.id, v),
                          decoration: InputDecoration(
                            labelText: isBox
                                ? 'Precio por caja'
                                : 'Precio por unidad',
                            prefixText: 'Bs ',
                            errorText: line.priceText.isEmpty
                                ? null
                                : validateMoney(line.priceText, required: true),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (unitCost != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Total ($units u)',
                      value: total!.format(),
                      emphasis: true,
                    ),
                    if (isBox)
                      _InfoRow(
                        label: 'Sale a',
                        value: '${unitCost.format()} c/u',
                      ),
                    Text(
                      averagePreview!,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `label ............ value`, used for the computed figures of a line.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasis
        ? theme.textTheme.titleSmall
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
