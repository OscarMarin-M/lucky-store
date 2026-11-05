import 'package:flutter/material.dart';

/// "Cómo se calcula": the arithmetic behind a figure, one step per line
/// (see `format/cost_formula.dart`), on a tinted background so it reads as
/// an explanation and not as more data to type.
class FormulaBox extends StatelessWidget {
  const FormulaBox({super.key, required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cómo se calcula', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          for (final l in lines) ...[
            Text(l, style: muted),
            const SizedBox(height: 2),
          ],
        ],
      ),
    );
  }
}
