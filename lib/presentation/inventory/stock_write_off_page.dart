import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/quantity/presentation.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../common/quantity_stepper.dart';
import '../format/date_format.dart';
import '../format/stock_format.dart';
import '../theme/app_theme.dart';
import 'adjustment_labels.dart';

/// "Dar de baja": take units out of the inventory without a sale (merma,
/// vencido, consumo propio, otros). Promotional gifts are not done here: they
/// are a sale line at Bs 0.
class StockWriteOffPage extends ConsumerStatefulWidget {
  const StockWriteOffPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<StockWriteOffPage> createState() => _StockWriteOffPageState();
}

class _StockWriteOffPageState extends ConsumerState<StockWriteOffPage> {
  final _quantity = TextEditingController(text: '1');
  final _notes = TextEditingController();
  AdjustmentReason _reason = AdjustmentReason.shrinkage;
  Presentation _presentation = Presentation.unit;
  bool _saving = false;

  @override
  void dispose() {
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  int get _qty => int.tryParse(_quantity.text.trim()) ?? 0;

  /// What the write-off would do, or the reason it cannot be done.
  ({int units, Money loss, int remaining})? _preview(
    Product p, {
    required void Function(String) onError,
  }) {
    if (_qty < 1) return null;
    try {
      final units = toBaseUnits(
        quantity: _qty,
        presentation: _presentation,
        unitsPerBox: p.unitsPerBox,
      );
      final out = ref
          .read(costStrategyProvider)
          .applyOutflow(
            p.stockState,
            units: units,
            allowNegativeStock: ref
                .read(inventoryPolicyProvider)
                .allowNegativeStock,
          );
      return (units: units, loss: out.totalCost, remaining: out.newState.units);
    } on InsufficientStockException catch (e) {
      onError(
        'Stock insuficiente: hay ${e.available} u y quieres dar de baja ${e.requested} u',
      );
      return null;
    }
  }

  Future<void> _save(Product p) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      final adj = await ref.read(registerStockAdjustmentProvider)(
        productId: p.id,
        quantity: _qty,
        presentation: _presentation,
        reason: _reason,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${reasonLabel(_reason)}: ${adj.unitsBase} u de "${p.name}" · pérdida ${adj.costTotal.format()}',
            ),
          ),
        );
    } on DomainException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    // Live copy: stock changes as write-offs are registered.
    final live =
        ref
            .watch(productsProvider)
            .value
            ?.where((x) => x.id == widget.product.id)
            .firstOrNull ??
        widget.product;

    String? error;
    final preview = _preview(live, onError: (m) => error = m);
    final history =
        ref.watch(productAdjustmentsProvider(live.id)).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Dar de baja')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(live.name, style: theme.textTheme.titleLarge),
          Text(
            'Stock: ${formatStock(live.stockUnits, live.unitsPerBox)}'
            '${live.stockUnits > 0 && live.unitsPerBox > 1 ? ' (${live.stockUnits} u)' : ''}',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 16),
          Text('Motivo', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in AdjustmentReason.values)
                ChoiceChip(
                  avatar: Icon(reasonIcon(r), size: 18),
                  label: Text(reasonLabel(r)),
                  selected: _reason == r,
                  onSelected: (_) => setState(() => _reason = r),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Un regalo por oferta se registra en la venta, con precio Bs 0.',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 16),
          if (live.unitsPerBox > 1) ...[
            SegmentedButton<Presentation>(
              showSelectedIcon: false,
              segments: [
                const ButtonSegment(
                  value: Presentation.unit,
                  label: Text('Unidad'),
                ),
                ButtonSegment(
                  value: Presentation.box,
                  label: Text('Caja (${live.unitsPerBox} u)'),
                ),
              ],
              selected: {_presentation},
              onSelectionChanged: (s) =>
                  setState(() => _presentation = s.first),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              QuantityStepper(
                controller: _quantity,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(width: 12),
              Text(
                _presentation == Presentation.box ? 'cajas' : 'unidades',
                style: TextStyle(color: muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Nota (opcional)'),
          ),
          const SizedBox(height: 16),
          if (error != null)
            Text(error!, style: TextStyle(color: theme.colorScheme.loss))
          else if (preview != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Se descuentan ${preview.units} u'),
                    Text(
                      'Pérdida: ${preview.loss.format()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.loss,
                      ),
                    ),
                    Text(
                      'Quedan: ${formatStock(preview.remaining, live.unitsPerBox)}',
                      style: TextStyle(color: muted),
                    ),
                  ],
                ),
              ),
            ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Bajas anteriores', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final a in history)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(reasonIcon(a.reason)),
                title: Text('${reasonLabel(a.reason)} · ${a.unitsBase} u'),
                subtitle: Text(
                  [
                    formatDate(a.date),
                    if (a.notes != null) a.notes!,
                  ].join(' · '),
                ),
                trailing: Text(
                  '-${a.costTotal.format()}',
                  style: TextStyle(color: theme.colorScheme.loss),
                ),
              ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: preview != null && !_saving ? () => _save(live) : null,
            child: const Text('Dar de baja'),
          ),
        ),
      ),
    );
  }
}
