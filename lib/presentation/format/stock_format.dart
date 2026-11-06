import '../../core/quantity/presentation.dart';
import '../../domain/entities/product.dart';

/// Human text for a stock level: whole packs first, loose units after.
///
/// `formatStock(53, 24)` -> `2 cajas + 5 u`; with [pack] = bag,
/// `formatStock(65, 30, pack: Presentation.bag)` -> `2 bolsas + 5 u`.
/// A [packSize] of 1 or less just shows units. Stock is kept in units, so
/// selling loose units out of a bag lowers the count of whole bags.
String formatStock(
  int units,
  int packSize, {
  Presentation pack = Presentation.box,
}) {
  if (units == 0) return 'Sin stock';
  if (units < 0) return '$units u';
  if (packSize <= 1 || !pack.isPack) return '$units u';

  final packs = units ~/ packSize;
  final loose = units % packSize;
  final parts = <String>[
    if (packs > 0) '$packs ${pack.nameFor(packs)}',
    if (loose > 0) '$loose u',
  ];
  return parts.join(' + ');
}

/// The pack a product's stock is counted in: its box, else its bag (a
/// product with both shows boxes, the bigger pack), else plain units.
Presentation stockPackOf(Product p) => p.hasBoxes
    ? Presentation.box
    : p.hasBags
        ? Presentation.bag
        : Presentation.unit;

/// [formatStock] with the product's own pack; [units] defaults to its stock.
String formatProductStock(Product p, {int? units}) {
  final pack = stockPackOf(p);
  return formatStock(
    units ?? p.stockUnits,
    p.unitsIn(pack) ?? 1,
    pack: pack,
  );
}

/// How a document line was counted: `2 cajas de 24 u`, `1 bolsa de 30 u` or
/// `10 u`. [packSize] is the pack size of that line (it can differ per
/// lot), derived from [unitsBase] when the line did not store it.
String formatLineQuantity({
  required int quantity,
  required Presentation presentation,
  required int unitsBase,
  int? packSize,
}) {
  if (!presentation.isPack) return '$quantity u';
  final size = packSize ?? (quantity == 0 ? 0 : unitsBase ~/ quantity);
  return '$quantity ${presentation.nameFor(quantity)} de $size u';
}
