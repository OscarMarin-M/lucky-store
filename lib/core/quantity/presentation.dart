import '../errors/domain_exception.dart';

/// How a quantity was expressed in a purchase/sale/adjustment.
///
/// Inventory and costing only ever see base units: use [toBaseUnits] at the
/// edge and the rest of the domain does not know boxes or bags exist. A
/// product without boxes is simply `unitsPerBox = 1`; one without bags has
/// `unitsPerBag = null`.
///
/// Stored by name in the database and in the cloud ('unit', 'box', 'bag'):
/// never rename a value.
enum Presentation {
  unit,
  box,

  /// v10. A sealed bag of ONE product (the shop does not buy mixed bags).
  /// Same rules as a box, its own size per product and per lot.
  bag;

  /// "caja" / "bolsa" / "u", for texts like "2 cajas de 24 u".
  String nameFor(int quantity) => switch (this) {
        Presentation.unit => 'u',
        Presentation.box => quantity == 1 ? 'caja' : 'cajas',
        Presentation.bag => quantity == 1 ? 'bolsa' : 'bolsas',
      };

  /// Capitalized singular for buttons and labels ("Caja", "Bolsa").
  String get label => switch (this) {
        Presentation.unit => 'Unidad',
        Presentation.box => 'Caja',
        Presentation.bag => 'Bolsa',
      };

  /// Suffix of a price per presentation: "c/u", "c/caja", "c/bolsa".
  String get eachSuffix => switch (this) {
        Presentation.unit => 'c/u',
        Presentation.box => 'c/caja',
        Presentation.bag => 'c/bolsa',
      };

  /// Box and bag are packs: priced and sized as a whole.
  bool get isPack => this != Presentation.unit;
}

/// Converts [quantity] expressed in [presentation] to base units.
///
/// [unitsPerBag] is null for a product that has no bags; asking to convert
/// bags of such a product is a bug in the caller (the UI hides the option).
int toBaseUnits({
  required int quantity,
  required Presentation presentation,
  required int unitsPerBox,
  int? unitsPerBag,
}) {
  if (quantity <= 0) throw InvalidQuantityException(quantity);
  if (unitsPerBox < 1) throw InvalidUnitsPerBoxException(unitsPerBox);
  return switch (presentation) {
    Presentation.unit => quantity,
    Presentation.box => quantity * unitsPerBox,
    Presentation.bag => quantity * _bagSize(unitsPerBag),
  };
}

int _bagSize(int? unitsPerBag) {
  if (unitsPerBag == null) throw const MissingBagSizeException();
  if (unitsPerBag < 1) throw InvalidUnitsPerBagException(unitsPerBag);
  return unitsPerBag;
}
