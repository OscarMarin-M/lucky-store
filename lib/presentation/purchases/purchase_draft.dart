import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../core/quantity/presentation.dart';
import '../../core/util/clock.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/purchasing/purchase_lot.dart';
import '../../domain/usecases/register_purchase.dart';
import '../common/validators.dart';

/// What the owner has typed for one lot, field by field (texts stay raw so
/// the fields keep exactly what was written). Each way of buying has its own
/// form; [build] turns it into the domain [PurchaseLot], which owns the rules.
sealed class LotForm {
  const LotForm();

  Presentation get mode;

  /// The lot, or null while a field is missing/unparseable. Throws a
  /// [DomainException] when the fields parse but break a rule.
  PurchaseLot? build();
}

/// Sealed box from a supplier: price of one box, size of THIS box, one
/// expiry date and the code printed on it.
final class BoxLotForm extends LotForm {
  const BoxLotForm({
    this.boxes = 1,
    required this.unitsPerBoxText,
    this.priceText = '',
    this.expiry,
    this.lotCode = '',
  });

  /// The product's usual box size is only a starting point.
  factory BoxLotForm.forProduct(Product p) =>
      BoxLotForm(unitsPerBoxText: '${p.unitsPerBox}');

  final int boxes;
  final String unitsPerBoxText;
  final String priceText;
  final DateTime? expiry;
  final String lotCode;

  int? get unitsPerBox => int.tryParse(unitsPerBoxText.trim());

  @override
  Presentation get mode => Presentation.box;

  @override
  PurchaseLot? build() {
    final price = tryParseMoney(priceText);
    final size = unitsPerBox;
    if (price == null || size == null || boxes < 1) return null;
    return BoxLot(
      boxes: boxes,
      unitsPerBox: size,
      pricePerBox: price,
      expiry: expiry,
      lotCode: lotCode,
    );
  }

  BoxLotForm copyWith({
    int? boxes,
    String? unitsPerBoxText,
    String? priceText,
    DateTime? Function()? expiry,
    String? lotCode,
  }) => BoxLotForm(
    boxes: boxes ?? this.boxes,
    unitsPerBoxText: unitsPerBoxText ?? this.unitsPerBoxText,
    priceText: priceText ?? this.priceText,
    expiry: expiry != null ? expiry() : this.expiry,
    lotCode: lotCode ?? this.lotCode,
  );
}

/// Loose units are counted, or derived from the money spent.
enum LooseEntry { quantity, amount }

/// Informal purchase of loose units: price per unit, then either how many
/// or how much was spent, and an expiry range (units may not match).
final class LooseLotForm extends LotForm {
  const LooseLotForm({
    this.entry = LooseEntry.quantity,
    this.units = 1,
    this.unitPriceText = '',
    this.amountText = '',
    this.expiryFrom,
    this.expiryTo,
  });

  final LooseEntry entry;
  final int units;
  final String unitPriceText;
  final String amountText;
  final DateTime? expiryFrom;
  final DateTime? expiryTo;

  @override
  Presentation get mode => Presentation.unit;

  @override
  PurchaseLot? build() {
    final price = tryParseMoney(unitPriceText);
    if (price == null) return null;
    switch (entry) {
      case LooseEntry.quantity:
        if (units < 1) return null;
        return LooseUnitsLot(
          units: units,
          unitPrice: price,
          expiryFrom: expiryFrom,
          expiryTo: expiryTo,
        );
      case LooseEntry.amount:
        final amount = tryParseMoney(amountText);
        if (amount == null) return null;
        return LooseUnitsLot.byAmount(
          amount: amount,
          unitPrice: price,
          expiryFrom: expiryFrom,
          expiryTo: expiryTo,
        );
    }
  }

  LooseLotForm copyWith({
    LooseEntry? entry,
    int? units,
    String? unitPriceText,
    String? amountText,
    DateTime? Function()? expiryFrom,
    DateTime? Function()? expiryTo,
  }) => LooseLotForm(
    entry: entry ?? this.entry,
    units: units ?? this.units,
    unitPriceText: unitPriceText ?? this.unitPriceText,
    amountText: amountText ?? this.amountText,
    expiryFrom: expiryFrom != null ? expiryFrom() : this.expiryFrom,
    expiryTo: expiryTo != null ? expiryTo() : this.expiryTo,
  );
}

/// One product being bought, as one lot.
class DraftPurchaseLine {
  DraftPurchaseLine({
    required this.id,
    required this.product,
    required this.form,
  });

  /// Starts as a box when the product usually comes in boxes.
  factory DraftPurchaseLine.forProduct(Product product) => DraftPurchaseLine(
    id: newId(),
    product: product,
    form: product.unitsPerBox > 1
        ? BoxLotForm.forProduct(product)
        : const LooseLotForm(),
  );

  final String id;
  final Product product;
  final LotForm form;

  Presentation get mode => form.mode;

  late final (PurchaseLot?, String?) _built = () {
    try {
      return (form.build(), null);
    } on DomainException catch (e) {
      return (null, e.message);
    }
  }();

  /// The valid lot, or null while incomplete or rejected.
  PurchaseLot? get lot => _built.$1;

  /// Why the domain rejected what was typed (e.g. an amount that does not
  /// buy whole units). Null while the fields are just incomplete.
  String? get ruleError => _built.$2;

  Money? get lineTotal => lot?.lineTotal;
  int? get unitsBase => lot?.unitsBase;

  /// What each base unit comes out at ("sale a").
  UnitCost? get unitCost => lot?.unitCost;

  bool get isValid => lot != null;

  DraftPurchaseLine withForm(LotForm form) =>
      DraftPurchaseLine(id: id, product: product, form: form);
}

class PurchaseDraftState {
  const PurchaseDraftState({
    this.lines = const [],
    this.date,
    this.supplier = '',
    this.notes = '',
  });

  final List<DraftPurchaseLine> lines;

  /// Null = "today" (resolved when registering).
  final DateTime? date;
  final String supplier;
  final String notes;

  bool get canSubmit => lines.isNotEmpty && lines.every((l) => l.isValid);

  /// Sum of the valid line totals typed so far.
  Money get total => lines
      .map((l) => l.lineTotal ?? Money.zero)
      .fold(Money.zero, (a, b) => a + b);

  PurchaseDraftState copyWith({
    List<DraftPurchaseLine>? lines,
    DateTime? date,
    String? supplier,
    String? notes,
  }) => PurchaseDraftState(
    lines: lines ?? this.lines,
    date: date ?? this.date,
    supplier: supplier ?? this.supplier,
    notes: notes ?? this.notes,
  );
}

class PurchaseDraft extends Notifier<PurchaseDraftState> {
  @override
  PurchaseDraftState build() => const PurchaseDraftState();

  void addProduct(Product product) {
    state = state.copyWith(
      lines: [...state.lines, DraftPurchaseLine.forProduct(product)],
    );
  }

  void removeLine(String id) {
    state = state.copyWith(
      lines: state.lines.where((l) => l.id != id).toList(),
    );
  }

  /// Box and loose purchases ask for different things, so switching starts a
  /// blank form: a box price is never kept as a unit price by accident.
  void setMode(String id, Presentation mode) => _updateLine(
    id,
    (l) => l.mode == mode
        ? l
        : l.withForm(
            mode == Presentation.box
                ? BoxLotForm.forProduct(l.product)
                : const LooseLotForm(),
          ),
  );

  /// Replaces the line's form; it must keep the line's current mode.
  void updateForm(String id, LotForm form) =>
      _updateLine(id, (l) => l.mode == form.mode ? l.withForm(form) : l);

  void _updateLine(String id, DraftPurchaseLine Function(DraftPurchaseLine) f) {
    state = state.copyWith(
      lines: [for (final l in state.lines) l.id == id ? f(l) : l],
    );
  }

  void setDate(DateTime date) => state = state.copyWith(date: date);
  void setSupplier(String value) => state = state.copyWith(supplier: value);
  void setNotes(String value) => state = state.copyWith(notes: value);

  void clear() => state = const PurchaseDraftState();

  /// Registers the purchase and empties the draft. Throws a
  /// `DomainException` (draft kept) if the rules reject it.
  Future<Purchase> submit() async {
    final draft = state;
    final purchase = await ref.read(registerPurchaseProvider)(
      date: draft.date,
      supplier: draft.supplier.trim().isEmpty ? null : draft.supplier.trim(),
      notes: draft.notes.trim().isEmpty ? null : draft.notes.trim(),
      lines: [
        for (final l in draft.lines)
          PurchaseLineInput(productId: l.product.id, lot: l.lot!),
      ],
    );
    clear();
    return purchase;
  }
}

final purchaseDraftProvider =
    NotifierProvider<PurchaseDraft, PurchaseDraftState>(PurchaseDraft.new);
