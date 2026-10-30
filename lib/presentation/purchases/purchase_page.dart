import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/domain_exception.dart';
import '../../core/quantity/presentation.dart';
import '../../domain/purchasing/purchase_lot.dart';
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

/// One lot: the owner first says HOW it was bought (box or loose units) and
/// the form below changes, because each way asks for different data.
class _LineCard extends ConsumerWidget {
  const _LineCard({super.key, required this.line});

  final DraftPurchaseLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(purchaseDraftProvider.notifier);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    line.product.name,
                    style: theme.textTheme.titleMedium,
                  ),
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
                  SegmentedButton<Presentation>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: Presentation.box,
                        icon: Icon(Icons.inventory_2_outlined),
                        label: Text('Caja'),
                      ),
                      ButtonSegment(
                        value: Presentation.unit,
                        icon: Icon(Icons.scatter_plot_outlined),
                        label: Text('Por unidades'),
                      ),
                    ],
                    selected: {line.mode},
                    onSelectionChanged: (s) =>
                        notifier.setMode(line.id, s.first),
                  ),
                  const SizedBox(height: 12),
                  // Keyed by mode: switching builds fresh fields/controllers.
                  switch (line.form) {
                    BoxLotForm f => _BoxLotFields(
                      key: ValueKey('${line.id}-box'),
                      form: f,
                      onChanged: (next) => notifier.updateForm(line.id, next),
                    ),
                    LooseLotForm f => _LooseLotFields(
                      key: ValueKey('${line.id}-loose'),
                      form: f,
                      onChanged: (next) => notifier.updateForm(line.id, next),
                    ),
                  },
                  _LotSummary(line: line),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Box: how many boxes and the price of ONE, the size of this box (it changes
/// between suppliers), its code and its single expiry date.
class _BoxLotFields extends StatefulWidget {
  const _BoxLotFields({super.key, required this.form, required this.onChanged});

  final BoxLotForm form;
  final ValueChanged<BoxLotForm> onChanged;

  @override
  State<_BoxLotFields> createState() => _BoxLotFieldsState();
}

class _BoxLotFieldsState extends State<_BoxLotFields> {
  late final _boxes = TextEditingController(text: '${widget.form.boxes}');
  late final _size = TextEditingController(text: widget.form.unitsPerBoxText);
  late final _price = TextEditingController(text: widget.form.priceText);
  late final _code = TextEditingController(text: widget.form.lotCode);

  @override
  void dispose() {
    _boxes.dispose();
    _size.dispose();
    _price.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final size = form.unitsPerBox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuantityStepper(
              controller: _boxes,
              onChanged: (q) => widget.onChanged(form.copyWith(boxes: q)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MoneyField(
                controller: _price,
                label: 'Precio por caja',
                onChanged: (v) => widget.onChanged(form.copyWith(priceText: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _size,
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    widget.onChanged(form.copyWith(unitsPerBoxText: v)),
                decoration: InputDecoration(
                  labelText: 'Unidades por caja',
                  errorText: form.unitsPerBoxText.isEmpty ||
                          (size != null && size >= 1)
                      ? null
                      : 'Mínimo 1',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                onChanged: (v) => widget.onChanged(form.copyWith(lotCode: v)),
                decoration: const InputDecoration(
                  labelText: 'Código (opcional)',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          children: [
            _ExpiryChip(
              label: 'Vence',
              value: form.expiry,
              onChanged: (d) => widget.onChanged(form.copyWith(expiry: () => d)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Loose units: price per unit, then either the count or the money spent,
/// and an expiry range since informal lots are not uniform.
class _LooseLotFields extends StatefulWidget {
  const _LooseLotFields({
    super.key,
    required this.form,
    required this.onChanged,
  });

  final LooseLotForm form;
  final ValueChanged<LooseLotForm> onChanged;

  @override
  State<_LooseLotFields> createState() => _LooseLotFieldsState();
}

class _LooseLotFieldsState extends State<_LooseLotFields> {
  late final _units = TextEditingController(text: '${widget.form.units}');
  late final _price = TextEditingController(text: widget.form.unitPriceText);
  late final _amount = TextEditingController(text: widget.form.amountText);

  @override
  void dispose() {
    _units.dispose();
    _price.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final byAmount = form.entry == LooseEntry.amount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MoneyField(
          controller: _price,
          label: 'Precio por unidad',
          onChanged: (v) => widget.onChanged(form.copyWith(unitPriceText: v)),
        ),
        const SizedBox(height: 12),
        SegmentedButton<LooseEntry>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: LooseEntry.quantity, label: Text('Cantidad')),
            ButtonSegment(value: LooseEntry.amount, label: Text('Monto pagado')),
          ],
          selected: {form.entry},
          onSelectionChanged: (s) =>
              widget.onChanged(form.copyWith(entry: s.first)),
        ),
        const SizedBox(height: 12),
        if (byAmount)
          _MoneyField(
            controller: _amount,
            label: 'Monto pagado',
            onChanged: (v) => widget.onChanged(form.copyWith(amountText: v)),
          )
        else
          Row(
            children: [
              QuantityStepper(
                controller: _units,
                onChanged: (q) => widget.onChanged(form.copyWith(units: q)),
              ),
              const SizedBox(width: 12),
              const Text('unidades'),
            ],
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _ExpiryChip(
              label: 'Vence desde',
              value: form.expiryFrom,
              onChanged: (d) =>
                  widget.onChanged(form.copyWith(expiryFrom: () => d)),
            ),
            _ExpiryChip(
              label: 'hasta',
              value: form.expiryTo,
              firstDate: form.expiryFrom,
              onChanged: (d) =>
                  widget.onChanged(form.copyWith(expiryTo: () => d)),
            ),
          ],
        ),
      ],
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'Bs ',
        errorText: text.isEmpty ? null : validateMoney(text, required: true),
      ),
    );
  }
}

/// Optional expiry date: tap to pick, the x removes it.
class _ExpiryChip extends StatelessWidget {
  const _ExpiryChip({
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  /// Earliest selectable day (the start of a range for its end).
  final DateTime? firstDate;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final first = firstDate ?? DateTime(now.year - 1);
    final picked = await showDatePicker(
      context: context,
      helpText: 'Fecha de vencimiento',
      initialDate: value ?? (first.isAfter(now) ? first : now),
      firstDate: first,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final v = value;
    return InputChip(
      avatar: const Icon(Icons.event_busy_outlined, size: 18),
      label: Text(v == null ? '$label (opcional)' : '$label ${formatDate(v)}'),
      onPressed: () => _pick(context),
      onDeleted: v == null ? null : () => onChanged(null),
      deleteButtonTooltipMessage: 'Quitar fecha',
    );
  }
}

/// What the typed lot amounts to, and how it moves the average cost.
class _LotSummary extends ConsumerWidget {
  const _LotSummary({required this.line});

  final DraftPurchaseLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final error = line.ruleError;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          error,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }
    final lot = line.lot;
    if (lot == null) return const SizedBox.shrink();

    final product = line.product;
    final next = ref.read(costStrategyProvider).applyPurchase(
          product.stockState,
          units: lot.unitsBase,
          total: lot.lineTotal,
        );
    final averagePreview = product.stockUnits > 0
        ? 'Costo promedio pasa de ${product.avgCost.format()} a ${next.avgCost.format()}'
        : 'Costo promedio: ${next.avgCost.format()}';

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoRow(
            label: 'Total (${lot.unitsBase} u)',
            value: lot.lineTotal.format(),
            emphasis: true,
          ),
          // A box price hides the unit cost; a loose lot by amount hides the
          // count. Show the figure the owner did not type.
          switch (lot) {
            BoxLot() => _InfoRow(
              label: 'Sale a',
              value: '${lot.unitCost.format()} c/u',
            ),
            LooseUnitsLot(:final units) => _InfoRow(
              label: 'Unidades',
              value: '$units',
            ),
          },
          Text(
            averagePreview,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
