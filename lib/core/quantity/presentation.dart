import '../errors/domain_exception.dart';

/// How a quantity was expressed in a purchase/sale/adjustment.
///
/// Inventory and costing only ever see base units: use [toBaseUnits] at the
/// edge and the rest of the domain does not know boxes exist. A product
/// without boxes is simply `unitsPerBox = 1`.
enum Presentation { unit, box }

/// Converts [quantity] expressed in [presentation] to base units.
int toBaseUnits({
  required int quantity,
  required Presentation presentation,
  required int unitsPerBox,
}) {
  if (quantity <= 0) throw InvalidQuantityException(quantity);
  if (unitsPerBox < 1) throw InvalidUnitsPerBoxException(unitsPerBox);
  return switch (presentation) {
    Presentation.unit => quantity,
    Presentation.box => quantity * unitsPerBox,
  };
}
