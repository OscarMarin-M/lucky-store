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
