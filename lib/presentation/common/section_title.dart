import 'package:flutter/material.dart';

/// Section header that stands out from the cards: icon, larger bold text in
/// the accent color and a rule to the edge.
class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.text, {
    super.key,
    required this.icon,
    this.color,
  });

  final String text;
  final IconData icon;

  /// Defaults to the theme accent; "Atención" uses a warning tone.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 28, 2, 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: c),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: c,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: c.withValues(alpha: 0.35))),
        ],
      ),
    );
  }
}
