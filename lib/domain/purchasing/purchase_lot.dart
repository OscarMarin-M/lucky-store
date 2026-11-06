import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../core/quantity/presentation.dart';

/// One lot entering stock in a purchase. The shop buys in two ways and each
/// one is typed differently, so each has its own rules:
///
/// * [BoxLot]: a sealed box from a regular supplier. The size of the box
///   belongs to THIS lot (suppliers bring 24 or 36), it has one expiry date
///   and maybe a code printed on the box.
/// * [BagLot] (v10): a sealed bag of one product, same rules as a box.
/// * [LooseUnitsLot]: loose units bought informally (offers, street sellers).
///   Priced per unit; the expiry dates may differ between units, so it keeps
///   a range.
///
/// Both reduce to "N base units for a total of Bs X": that is all the costing
/// sees, so profit tracking does not depend on how the lot was bought.
sealed class PurchaseLot {
  const PurchaseLot();

  /// Units that enter stock.
  int get unitsBase;

  /// What was paid for the whole lot.
  Money get lineTotal;

  /// How the quantity was typed, kept to show the purchase as it was made.
  Presentation get presentation;
  int get quantity;

  /// Pack size (box or bag) of this lot; null for loose units.
  int? get unitsPerBox;

  /// Earliest / latest expiry in the lot (equal for a box). Null = unknown.
  DateTime? get expiryFrom;
  DateTime? get expiryTo;

  String? get lotCode;

  UnitCost get unitCost => UnitCost.fromTotal(lineTotal, unitsBase);
}

/// A sealed pack (box or bag) of one product: N packs of the same size at
/// one price each, one expiry date and maybe a printed code. The size
/// belongs to THIS lot, the product's size is only the suggested default.
sealed class PackLot extends PurchaseLot {
  PackLot({
    required this.packs,
    required this.unitsPerPack,
    required this.pricePerPack,
    DateTime? expiry,
    String? lotCode,
  })  : expiry = _dateOnly(expiry),
        lotCode = _blankToNull(lotCode) {
    if (packs < 1) throw InvalidQuantityException(packs);
    _rejectNegative(pricePerPack);
  }

  final int packs;
  final int unitsPerPack;

  /// Price of ONE pack: the owner reads it off the invoice or asks the
  /// seller, and the app multiplies by [packs].
  final Money pricePerPack;
  final DateTime? expiry;
  @override
  final String? lotCode;

  @override
  int get unitsBase => packs * unitsPerPack;
  @override
  Money get lineTotal => pricePerPack.times(packs);
  @override
  int get quantity => packs;

  /// Stored in the lot's pack size column whatever the pack is.
  @override
  int get unitsPerBox => unitsPerPack;
  @override
  DateTime? get expiryFrom => expiry;
  @override
  DateTime? get expiryTo => expiry;
}

/// Sealed box from a regular supplier (24 or 36 depending on who brings it).
final class BoxLot extends PackLot {
  BoxLot({
    required int boxes,
    required int unitsPerBox,
    required Money pricePerBox,
    super.expiry,
    super.lotCode,
  }) : super(
          packs: boxes,
          unitsPerPack: _checkBox(unitsPerBox),
          pricePerPack: pricePerBox,
        );

  int get boxes => packs;
  Money get pricePerBox => pricePerPack;

  @override
  Presentation get presentation => Presentation.box;

  static int _checkBox(int size) {
    if (size < 1) throw InvalidUnitsPerBoxException(size);
    return size;
  }
}

/// v10. Bag of one product, often bought informally: its unit count is
/// asked to the seller and may differ from the product's usual bag.
final class BagLot extends PackLot {
  BagLot({
    required int bags,
    required int unitsPerBag,
    required Money pricePerBag,
    super.expiry,
    super.lotCode,
  }) : super(
          packs: bags,
          unitsPerPack: _checkBag(unitsPerBag),
          pricePerPack: pricePerBag,
        );

  int get bags => packs;
  Money get pricePerBag => pricePerPack;

  @override
  Presentation get presentation => Presentation.bag;

  static int _checkBag(int size) {
    if (size < 1) throw InvalidUnitsPerBagException(size);
    return size;
  }
}

final class LooseUnitsLot extends PurchaseLot {
  LooseUnitsLot({
    required this.units,
    required this.unitPrice,
    DateTime? expiryFrom,
    DateTime? expiryTo,
  })  : expiryFrom = _dateOnly(expiryFrom ?? expiryTo),
        expiryTo = _dateOnly(expiryTo ?? expiryFrom) {
    if (units < 1) throw InvalidQuantityException(units);
    _rejectNegative(unitPrice);
    final from = this.expiryFrom, to = this.expiryTo;
    if (from != null && to != null && to.isBefore(from)) {
      throw InvalidExpiryRangeException(from, to);
    }
  }

  /// "I spent Bs 20 on chewing gum at Bs 0,50 each": the units come from the
  /// amount. The amount must buy a whole number of units, otherwise the price
  /// or the amount was mistyped.
  factory LooseUnitsLot.byAmount({
    required Money amount,
    required Money unitPrice,
    DateTime? expiryFrom,
    DateTime? expiryTo,
  }) {
    if (unitPrice.cents <= 0) {
      throw const InvalidAmountException(
        'El precio por unidad debe ser mayor a 0 para calcular la cantidad',
      );
    }
    if (amount.cents <= 0 || amount.cents % unitPrice.cents != 0) {
      throw InvalidAmountException(
        '${amount.format()} no alcanza para un número exacto de unidades '
        'a ${unitPrice.format()} c/u',
      );
    }
    return LooseUnitsLot(
      units: amount.cents ~/ unitPrice.cents,
      unitPrice: unitPrice,
      expiryFrom: expiryFrom,
      expiryTo: expiryTo,
    );
  }

  final int units;
  final Money unitPrice;
  @override
  final DateTime? expiryFrom;
  @override
  final DateTime? expiryTo;

  @override
  int get unitsBase => units;
  @override
  Money get lineTotal => unitPrice.times(units);
  @override
  Presentation get presentation => Presentation.unit;
  @override
  int get quantity => units;
  @override
  int? get unitsPerBox => null;
  @override
  String? get lotCode => null;
}

void _rejectNegative(Money price) {
  if (price.isNegative) {
    throw const InvalidAmountException('El precio no puede ser negativo');
  }
}

/// Expiry is a calendar day: drop the time so comparisons are by day.
DateTime? _dateOnly(DateTime? d) =>
    d == null ? null : DateTime(d.year, d.month, d.day);

String? _blankToNull(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}
