import 'package:flutter/material.dart';

import '../../core/quantity/presentation.dart';
import '../../domain/entities/product.dart';

/// "Unidad | Caja (24 u) | Bolsa (30 u)" for a sale or write-off line. Only
/// the packs the product defines are offered (no bag size -> no "Bolsa"),
/// and nothing at all when units are the only choice.
class PresentationSelector extends StatelessWidget {
  const PresentationSelector({
    super.key,
    required this.product,
    required this.selected,
    required this.onChanged,
  });

  final Product product;
  final Presentation selected;
  final ValueChanged<Presentation> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = product.presentations;
    if (options.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SegmentedButton<Presentation>(
        showSelectedIcon: false,
        segments: [
          for (final p in options)
            ButtonSegment(
              value: p,
              label: Text(
                p.isPack ? '${p.label} (${product.unitsIn(p)} u)' : p.label,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

/// "Precio por caja" / "Precio por bolsa" / "Precio por unidad".
String pricePerLabel(Presentation p) =>
    'Precio por ${p == Presentation.unit ? 'unidad' : p.nameFor(1)}';
