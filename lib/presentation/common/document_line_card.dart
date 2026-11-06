import 'package:flutter/material.dart';

/// One product of a purchase or a sale. A bordered card with a tinted header
/// strip "1 · Snickers" so consecutive products are clearly apart even when
/// their forms are long; the number is also how explanations refer to an
/// earlier line ("línea 1").
class DocumentLineCard extends StatelessWidget {
  const DocumentLineCard({
    super.key,
    required this.number,
    required this.title,
    required this.onRemove,
    required this.child,
  });

  /// 1-based position in the document.
  final int number;
  final String title;
  final VoidCallback onRemove;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: scheme.secondaryContainer,
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: scheme.secondary,
                  child: Text(
                    '$number',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar',
                  icon: const Icon(Icons.close),
                  color: scheme.onSecondaryContainer,
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// "Agregar producto" of Comprar and Vender: the main action while building
/// the document, so a filled, tall button rather than an outlined one.
class AddProductButton extends StatelessWidget {
  const AddProductButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_circle_outline, size: 26),
        label: const Text('Agregar producto'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          textStyle: Theme.of(context).textTheme.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}
