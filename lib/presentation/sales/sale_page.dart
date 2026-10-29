import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/quantity/presentation.dart';
import '../common/validators.dart';
import '../format/date_format.dart';
import '../purchases/product_picker_sheet.dart';
import '../theme/app_theme.dart';
import 'sale_draft.dart';

/// "Vender" tab: a cart of products with editable prices.
class SalePage extends ConsumerStatefulWidget {
  const SalePage({super.key});

  @override
  ConsumerState<SalePage> createState() => _SalePageState();
}

class _SalePageState extends ConsumerState<SalePage> {
  bool _submitting = false;

  Future<void> _addProduct() async {
    final product = await pickProduct(context, forSale: true);
    if (product != null) ref.read(saleDraftProvider.notifier).addProduct(product);
  }

  Future<void> _pickDate() async {
    final draft = ref.read(saleDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) ref.read(saleDraftProvider.notifier).setDate(picked);
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _submitting = true);
    try {
      final sale = await ref.read(saleDraftProvider.notifier).submit();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            'Venta registrada · ${sale.total.format()} · ganancia ${sale.profit.format()}',
          ),
        ));
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
    final draft = ref.watch(saleDraftProvider);
    final notifier = ref.read(saleDraftProvider.notifier);
    final allowNegative = ref.watch(inventoryPolicyProvider).allowNegativeStock;
    final theme = Theme.of(context);
    final profit = draft.estimatedProfit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vender'),
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
                label: Text(draft.date == null ? 'Hoy' : formatDate(draft.date!)),
                onPressed: _pickDate,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final line in draft.lines) ...[
            _SaleLineCard(
              key: ValueKey(line.id),
              line: line,
              fitsStock: draft.fitsStock(line.product, allowNegativeStock: allowNegative),
              requestedUnits: draft.unitsByProduct[line.product.id] ?? 0,
            ),
            const SizedBox(height: 10),
          ],
          if (draft.lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.point_of_sale_outlined, size: 56, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Text('Agrega productos al carrito',
                      style: TextStyle(color: theme.colorScheme.outline)),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text('Agregar producto'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
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
              if (draft.lines.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ganancia estimada',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    Text(
                      profit.format(),
                      style: TextStyle(
                        color: profit.isNegative ? theme.colorScheme.loss : theme.colorScheme.gain,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: draft.canSubmit(allowNegativeStock: allowNegative) && !_submitting
                    ? _submit
                    : null,
                child: const Text('Cobrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaleLineCard extends ConsumerStatefulWidget {
  const _SaleLineCard({
    super.key,
    required this.line,
    required this.fitsStock,
    required this.requestedUnits,
  });

  final DraftSaleLine line;
  final bool fitsStock;

  /// Units of this product asked for by all lines of the cart.
  final int requestedUnits;

  @override
  ConsumerState<_SaleLineCard> createState() => _SaleLineCardState();
}

class _SaleLineCardState extends ConsumerState<_SaleLineCard> {
  late final TextEditingController _qty;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _qty = TextEditingController(text: '${widget.line.quantity}');
    _price = TextEditingController(text: widget.line.priceText);
  }

  /// The notifier can change the price (box/unit switch, gift toggle):
  /// mirror it into the field without fighting the user's typing.
  @override
  void didUpdateWidget(covariant _SaleLineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.line.priceText != _price.text) _price.text = widget.line.priceText;
    if (widget.line.quantity >= 1 && '${widget.line.quantity}' != _qty.text) {
      _qty.text = '${widget.line.quantity}';
    }
  }

  @override
  void dispose() {
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  void _setQuantity(int value) {
    final q = value < 1 ? 1 : value;
    _qty.text = '$q';
    ref.read(saleDraftProvider.notifier).setQuantity(widget.line.id, q);
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final product = line.product;
    final notifier = ref.read(saleDraftProvider.notifier);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final subtotal = line.lineTotal;
    final profit = line.estimatedProfit;
    final discount = line.discount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(product.name, style: theme.textTheme.titleMedium)),
                IconButton(
                  tooltip: 'Quitar',
                  icon: const Icon(Icons.close),
                  onPressed: () => notifier.removeLine(line.id),
                ),
              ],
            ),
            if (product.unitsPerBox > 1) ...[
              SegmentedButton<Presentation>(
                showSelectedIcon: false,
                segments: [
                  const ButtonSegment(value: Presentation.unit, label: Text('Unidad')),
                  ButtonSegment(
                    value: Presentation.box,
                    label: Text('Caja (${product.unitsPerBox} u)'),
                  ),
                ],
                selected: {line.presentation},
                onSelectionChanged: (s) => notifier.setPresentation(line.id, s.first),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Menos',
                  icon: const Icon(Icons.remove),
                  onPressed: () => _setQuantity(line.quantity - 1),
                ),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _qty,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => notifier.setQuantity(line.id, int.tryParse(v) ?? 0),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Más',
                  icon: const Icon(Icons.add),
                  onPressed: () => _setQuantity(line.quantity + 1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => notifier.setPrice(line.id, v),
                    decoration: InputDecoration(
                      labelText: line.presentation == Presentation.box
                          ? 'Precio por caja'
                          : 'Precio por unidad',
                      prefixText: 'Bs ',
                      isDense: true,
                      errorText: validateMoney(line.priceText, required: true),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilterChip(
                  avatar: const Icon(Icons.card_giftcard, size: 18),
                  label: const Text('Regalo'),
                  selected: line.isGift,
                  showCheckmark: false,
                  onSelected: (_) => notifier.toggleGift(line.id),
                ),
                const Spacer(),
                if (subtotal != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(subtotal.format(), style: theme.textTheme.titleMedium),
                      if (profit != null)
                        Text(
                          'Ganancia ${profit.format()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: profit.isNegative ? theme.colorScheme.loss : theme.colorScheme.gain,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            if (line.isGift)
              _Note('Regalo: el costo cuenta contra la ganancia de esta venta.', color: muted)
            else if (discount != null && discount > Money.zero)
              _Note(
                'Descuento ${discount.format()} (sugerido ${line.suggestedPrice.format()})',
                color: muted,
              ),
            if (!widget.fitsStock)
              _Note(
                'Stock insuficiente: hay ${product.stockUnits} u y el carrito pide ${widget.requestedUnits} u',
                color: theme.colorScheme.loss,
              ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
      );
}
