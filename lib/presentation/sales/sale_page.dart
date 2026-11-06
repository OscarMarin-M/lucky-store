import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/sync_indicator.dart';
import '../../app/providers.dart';
import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../common/presentation_selector.dart';
import '../common/quantity_stepper.dart';
import '../common/validators.dart';
import '../format/date_format.dart';
import '../purchases/product_picker_sheet.dart';
import '../theme/app_theme.dart';
import 'quote_sheet.dart';
import 'sale_draft.dart';

/// "Vender" tab: a cart (or "pedido") of products with editable prices, plus
/// optional extra charges for promo boxes (assembly, packaging...).
class SalePage extends ConsumerStatefulWidget {
  const SalePage({super.key});

  @override
  ConsumerState<SalePage> createState() => _SalePageState();
}

class _SalePageState extends ConsumerState<SalePage> {
  bool _submitting = false;
  final _notes = TextEditingController();

  /// Concepts offered as one-tap shortcuts; any other can be typed.
  static const _commonConcepts = ['Mano de obra', 'Empaque', 'Impresión'];

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    final product = await pickProduct(context, forSale: true);
    if (product != null) {
      ref.read(saleDraftProvider.notifier).addProduct(product);
    }
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
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Venta registrada · ${sale.total.format()} · ganancia ${sale.profit.format()}',
            ),
          ),
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
    final draft = ref.watch(saleDraftProvider);
    final notifier = ref.read(saleDraftProvider.notifier);
    final allowNegative = ref.watch(inventoryPolicyProvider).allowNegativeStock;
    final theme = Theme.of(context);
    final profit = draft.estimatedProfit;
    final charges = draft.customerChargesTotal;
    final costs = draft.shopCostsTotal;

    // Keep the note field in step when the cart is emptied after charging.
    ref.listen(saleDraftProvider, (_, next) {
      if (next.notes != _notes.text) _notes.text = next.notes;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vender'),
        actions: [
          if (draft.lines.isNotEmpty)
            TextButton(onPressed: notifier.clear, child: const Text('Vaciar')),
          const SyncIndicator(),
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
          for (final line in draft.lines) ...[
            _SaleLineCard(
              key: ValueKey(line.id),
              line: line,
              fitsStock: draft.fitsStock(
                line.product,
                allowNegativeStock: allowNegative,
              ),
              requestedUnits: draft.unitsByProduct[line.product.id] ?? 0,
            ),
            const SizedBox(height: 10),
          ],
          if (draft.lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.point_of_sale_outlined,
                    size: 56,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Agrega productos al carrito',
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
          if (draft.lines.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _notes,
              onChanged: notifier.setNotes,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre del pedido o nota (opcional)',
                hintText: 'Ej: Caja San Valentín para Ana',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cargos y costos adicionales',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              'Armado, empaque, impresión… Si lo paga el cliente se suma al '
              'total y a la ganancia; si lo paga la tienda se resta de la '
              'ganancia.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            for (final c in draft.extraCharges) ...[
              _ExtraChargeRow(key: ValueKey(c.id), charge: c),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final concept in _commonConcepts)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: Text(concept),
                    onPressed: () => notifier.addExtraCharge(concept),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Otro'),
                  onPressed: notifier.addExtraCharge,
                ),
              ],
            ),
          ],
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
              if (draft.lines.isNotEmpty && charges.cents > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Incluye cargos al cliente',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '+${charges.format()}',
                      style: TextStyle(color: theme.colorScheme.gain),
                    ),
                  ],
                ),
              if (draft.lines.isNotEmpty && costs.cents > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Costos que paga la tienda',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '-${costs.format()}',
                      style: TextStyle(color: theme.colorScheme.loss),
                    ),
                  ],
                ),
              if (draft.lines.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ganancia estimada',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      profit.format(),
                      style: TextStyle(
                        color: profit.isNegative
                            ? theme.colorScheme.loss
                            : theme.colorScheme.gain,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: draft.canQuote
                          ? () => showQuoteSheet(context, draft)
                          : null,
                      icon: const Icon(Icons.request_quote_outlined),
                      label: const Text('Cotización'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          draft.canSubmit(allowNegativeStock: allowNegative) &&
                              !_submitting
                          ? _submit
                          : null,
                      child: const Text('Cobrar'),
                    ),
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
    if (widget.line.priceText != _price.text) {
      _price.text = widget.line.priceText;
    }
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
                  PresentationSelector(
                    product: product,
                    selected: line.presentation,
                    onChanged: (p) => notifier.setPresentation(line.id, p),
                  ),
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
                            labelText: pricePerLabel(line.presentation),
                            prefixText: 'Bs ',
                            errorText: validateMoney(
                              line.priceText,
                              required: true,
                            ),
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
                            Text(
                              subtotal.format(),
                              style: theme.textTheme.titleMedium,
                            ),
                            if (profit != null)
                              Text(
                                'Ganancia ${profit.format()}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: profit.isNegative
                                      ? theme.colorScheme.loss
                                      : theme.colorScheme.gain,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                  if (line.isGift)
                    _Note(
                      'Regalo: el costo cuenta contra la ganancia de esta venta.',
                      color: muted,
                    )
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
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
    ),
  );
}

/// `[ concept ] [ Bs amount ] (x)` and below who pays it: one extra amount
/// of the order.
class _ExtraChargeRow extends ConsumerStatefulWidget {
  const _ExtraChargeRow({super.key, required this.charge});

  final DraftExtraCharge charge;

  @override
  ConsumerState<_ExtraChargeRow> createState() => _ExtraChargeRowState();
}

class _ExtraChargeRowState extends ConsumerState<_ExtraChargeRow> {
  late final _concept = TextEditingController(text: widget.charge.concept);
  late final _amount = TextEditingController(text: widget.charge.amountText);

  @override
  void dispose() {
    _concept.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(saleDraftProvider.notifier);
    final c = widget.charge;
    final amountError = c.amountText.isEmpty
        ? null
        : (validateMoney(c.amountText, required: true) ??
              (c.amount!.cents == 0 ? 'Mayor a 0' : null));
    final fields = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _concept,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (v) => notifier.updateExtraCharge(c.id, concept: v),
            decoration: InputDecoration(
              labelText: 'Concepto',
              errorText: c.concept.trim().isEmpty && c.amountText.isNotEmpty
                  ? 'Obligatorio'
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => notifier.updateExtraCharge(c.id, amountText: v),
            decoration: InputDecoration(
              labelText: 'Monto',
              prefixText: 'Bs ',
              errorText: amountError,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Quitar cargo',
          icon: const Icon(Icons.close),
          onPressed: () => notifier.removeExtraCharge(c.id),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fields,
        const SizedBox(height: 6),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: true,
              icon: Icon(Icons.person_outline),
              label: Text('Lo paga el cliente'),
            ),
            ButtonSegment(
              value: false,
              icon: Icon(Icons.storefront_outlined),
              label: Text('Lo paga la tienda'),
            ),
          ],
          selected: {c.paidByCustomer},
          onSelectionChanged: (s) =>
              notifier.updateExtraCharge(c.id, paidByCustomer: s.single),
        ),
      ],
    );
  }
}
