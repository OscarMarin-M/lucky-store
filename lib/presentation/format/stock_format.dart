/// Human text for a stock level: boxes first, loose units after.
///
/// `formatStock(53, 24)` -> `2 cajas + 5 u`; products without boxes
/// (`unitsPerBox == 1`) just show units.
String formatStock(int units, int unitsPerBox) {
  if (units == 0) return 'Sin stock';
  if (units < 0) return '$units u';
  if (unitsPerBox <= 1) return '$units u';

  final boxes = units ~/ unitsPerBox;
  final loose = units % unitsPerBox;
  final parts = <String>[
    if (boxes > 0) '$boxes ${boxes == 1 ? 'caja' : 'cajas'}',
    if (loose > 0) '$loose u',
  ];
  return parts.join(' + ');
}

/// How a document line was counted: `2 cajas de 24 u`, `1 caja de 36 u` or
/// `10 u`. [unitsPerBox] is the box size of that line (it can differ per
/// lot), derived from [unitsBase] when the line did not store it.
String formatLineQuantity({
  required int quantity,
  required bool isBox,
  required int unitsBase,
  int? unitsPerBox,
}) {
  if (!isBox) return '$quantity u';
  final size = unitsPerBox ?? (quantity == 0 ? 0 : unitsBase ~/ quantity);
  return '$quantity ${quantity == 1 ? 'caja' : 'cajas'} de $size u';
}
