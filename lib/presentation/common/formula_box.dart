import 'package:flutter/material.dart';

import '../format/cost_formula.dart';
import '../theme/app_theme.dart';

/// "Cómo se calcula": draws the steps of `format/cost_formula.dart` so the
/// owner sees where a cost or a profit comes from: equations as chips
/// (figure on top, meaning below), the purchase average as a bar of what is
/// mixed, and a price as a bar split into cost and profit.
class FormulaBox extends StatelessWidget {
  const FormulaBox({super.key, required this.steps});

  final List<FormulaStep> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                'Cómo se calcula',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          for (final step in steps) ...[
            const SizedBox(height: 12),
            switch (step) {
              Equation() => _EquationView(step),
              AverageMix() => _AverageMixView(step),
              PriceSplit() => _PriceSplitView(step),
              FormulaNote(:final text) => _NoteView(text),
            },
          ],
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

/// `[Bs 72,00 | precio caja] ÷ [36 u | unidades] = [Bs 2,0000 | c/u]`;
/// wraps on narrow phones.
class _EquationView extends StatelessWidget {
  const _EquationView(this.eq);

  final Equation eq;

  @override
  Widget build(BuildContext context) {
    final op = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(eq.title),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _TermChip(eq.left),
            Text(eq.op, style: op),
            _TermChip(eq.right),
            Text('=', style: op),
            _TermChip(eq.result, highlight: true),
          ],
        ),
      ],
    );
  }
}

class _TermChip extends StatelessWidget {
  const _TermChip(this.term, {this.highlight = false});

  final Term term;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? scheme.primaryContainer : scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: highlight ? null : Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            term.value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: highlight ? scheme.onPrimaryContainer : null,
            ),
          ),
          Text(
            term.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: highlight
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal bar split in proportional, colored parts.
class _SplitBar extends StatelessWidget {
  const _SplitBar(this.parts);

  /// (weight, color); a weight of 0 draws nothing.
  final List<(int, Color)> parts;

  @override
  Widget build(BuildContext context) {
    final visible = parts.where((p) => p.$1 > 0).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: SizedBox(
        height: 14,
        child: Row(
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Expanded(
                flex: visible[i].$1,
                child: ColoredBox(color: visible[i].$2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// `● label ........ value`, the legend under a bar.
class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final Color color;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CircleAvatar(radius: 5, backgroundColor: color),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// What is mixed (stock already held + this lot, by units) and the average
/// that comes out.
class _AverageMixView extends StatelessWidget {
  const _AverageMixView(this.mix);

  final AverageMix mix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final held = scheme.outline;
    final lot = scheme.purchase;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle('Mezcla con lo que ya tenías'),
        _SplitBar([(mix.heldUnits, held), (mix.lotUnits, lot)]),
        _LegendRow(
          color: held,
          label: 'En stock: ${mix.heldUnits} u × ${mix.heldCost.format()}',
          value: mix.heldValue.format(),
        ),
        _LegendRow(
          color: lot,
          label: 'Este lote: ${mix.lotUnits} u × ${mix.lotCost.format()}',
          value: mix.lotValue.format(),
        ),
        const SizedBox(height: 10),
        _EquationView(mix.result),
      ],
    );
  }
}

/// The price as a bar: the part that pays the cost and the part left as
/// profit. At a loss the whole bar is cost and the loss is shown in red.
class _PriceSplitView extends StatelessWidget {
  const _PriceSplitView(this.split);

  final PriceSplit split;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profit = split.profit;
    final losing = profit.cents < 0;
    final margin = split.marginPercent;
    final costLabel = split.costDetail == null
        ? 'Costo'
        : 'Costo (${split.costDetail})';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle('${split.title} · precio ${split.price.format()}'),
        _SplitBar([
          (losing ? 1 : split.cost.cents, scheme.purchase),
          (losing ? 0 : profit.cents, scheme.gain),
        ]),
        _LegendRow(
          color: scheme.purchase,
          label: costLabel,
          value: split.cost.format(),
        ),
        _LegendRow(
          color: losing ? scheme.loss : scheme.gain,
          label: [
            losing ? 'Pérdida' : 'Ganancia',
            if (margin != null) '${margin.toStringAsFixed(0)}% del precio',
          ].join(' · '),
          value: losing ? '-${(-profit).format()}' : profit.format(),
          valueColor: losing ? scheme.loss : scheme.gain,
        ),
      ],
    );
  }
}

class _NoteView extends StatelessWidget {
  const _NoteView(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16, color: muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ),
      ],
    );
  }
}
