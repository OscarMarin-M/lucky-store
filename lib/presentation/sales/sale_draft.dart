import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/money/money.dart';
import '../../core/quantity/presentation.dart';
import '../../core/util/clock.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/register_sale.dart';
import '../common/validators.dart';

/// One cart line. The price starts at the suggested one and can be edited;
/// a price of 0 is a promotional gift (its cost still counts in the sale).
class DraftSaleLine {
  const DraftSaleLine({
    required this.id,
    required this.product,
    required this.quantity,
    required this.presentation,
    required this.priceText,
  });

  factory DraftSaleLine.forProduct(Product product) => DraftSaleLine(
    id: newId(),
    product: product,
    quantity: 1,
    presentation: Presentation.unit,
    priceText: product
        .suggestedPriceFor(Presentation.unit)
        .format(symbol: false),
  );

  final String id;
  final Product product;
  final int quantity;
  final Presentation presentation;

  /// Price per [presentation], as typed.
  final String priceText;

  Money? get unitPrice => tryParseMoney(priceText);
  Money get suggestedPrice => product.suggestedPriceFor(presentation);
  bool get isGift => unitPrice?.isZero ?? false;

  int? get unitsBase => quantity < 1
      ? null
      : toBaseUnits(
          quantity: quantity,
          presentation: presentation,
          unitsPerBox: product.unitsPerBox,
        );

  Money? get lineTotal => quantity < 1 ? null : unitPrice?.times(quantity);

  /// Estimated with the average cost known when the line was added; the sale
  /// itself recomputes it with the current cost.
  Money? get estimatedProfit {
    final total = lineTotal;
    final units = unitsBase;
    if (total == null || units == null) return null;
    return total - product.avgCost.totalFor(units);
  }

  /// Taken off the suggested price in all (negative = charged more).
  Money? get discount {
    final price = unitPrice;
    if (price == null || quantity < 1) return null;
    return (suggestedPrice - price).times(quantity);
  }

  bool get hasValidPrice {
    final price = unitPrice;
    return price != null && !price.isNegative;
  }

  DraftSaleLine copyWith({
    int? quantity,
    Presentation? presentation,
    String? priceText,
  }) => DraftSaleLine(
    id: id,
    product: product,
    quantity: quantity ?? this.quantity,
    presentation: presentation ?? this.presentation,
    priceText: priceText ?? this.priceText,
  );
}

/// An amount of the order that is not a product (assembly, packaging...), as
/// typed. Charged to the customer it adds to the total and to the profit;
/// paid by the shop it only lowers the profit.
class DraftExtraCharge {
  const DraftExtraCharge({
    required this.id,
    this.concept = '',
    this.amountText = '',
    this.paidByCustomer = true,
  });

  final String id;
  final String concept;
  final String amountText;
  final bool paidByCustomer;

  Money? get amount => tryParseMoney(amountText);

  /// The amount if the row is valid, zero while it is being typed.
  Money get validAmount => isValid ? amount! : Money.zero;

  /// A row the owner added but left untouched: ignored, not an error.
  bool get isBlank => concept.trim().isEmpty && amountText.trim().isEmpty;

  bool get isValid {
    final a = amount;
    return concept.trim().isNotEmpty && a != null && a.cents > 0;
  }

  DraftExtraCharge copyWith({
    String? concept,
    String? amountText,
    bool? paidByCustomer,
  }) => DraftExtraCharge(
    id: id,
    concept: concept ?? this.concept,
    amountText: amountText ?? this.amountText,
    paidByCustomer: paidByCustomer ?? this.paidByCustomer,
  );
}

class SaleDraftState {
  const SaleDraftState({
    this.lines = const [],
    this.date,
    this.extraCharges = const [],
    this.notes = '',
  });

  final List<DraftSaleLine> lines;

  /// Null = now (resolved when registering).
  final DateTime? date;

  final List<DraftExtraCharge> extraCharges;

  /// Names the order, e.g. "Caja San Valentín para Ana".
  final String notes;

  /// Extra charges that will be registered (blank rows are skipped).
  Iterable<DraftExtraCharge> get filledExtraCharges =>
      extraCharges.where((c) => !c.isBlank);

  /// Charged to the customer on top of the products.
  Money get customerChargesTotal => filledExtraCharges
      .where((c) => c.paidByCustomer)
      .map((c) => c.validAmount)
      .sum;

  /// Costs of the order the shop absorbs.
  Money get shopCostsTotal => filledExtraCharges
      .where((c) => !c.paidByCustomer)
      .map((c) => c.validAmount)
      .sum;

  /// Base units requested per product across all lines.
  Map<String, int> get unitsByProduct {
    final map = <String, int>{};
    for (final l in lines) {
      final units = l.unitsBase;
      if (units != null) {
        map.update(l.product.id, (v) => v + units, ifAbsent: () => units);
      }
    }
    return map;
  }

  /// Whether the lines of [product] together fit in its stock.
  bool fitsStock(Product product, {required bool allowNegativeStock}) =>
      allowNegativeStock ||
      (unitsByProduct[product.id] ?? 0) <= product.stockUnits;

  bool canSubmit({required bool allowNegativeStock}) =>
      lines.isNotEmpty &&
      lines.every(
        (l) =>
            l.quantity >= 1 &&
            l.hasValidPrice &&
            fitsStock(l.product, allowNegativeStock: allowNegativeStock),
      ) &&
      filledExtraCharges.every((c) => c.isValid);

  Money get productsTotal =>
      lines.map((l) => l.lineTotal ?? Money.zero).sum;

  /// What the customer pays: products plus the charges they pay.
  Money get total => productsTotal + customerChargesTotal;

  Money get estimatedProfit =>
      lines.map((l) => l.estimatedProfit ?? Money.zero).sum +
      customerChargesTotal -
      shopCostsTotal;

  SaleDraftState copyWith({
    List<DraftSaleLine>? lines,
    DateTime? date,
    List<DraftExtraCharge>? extraCharges,
    String? notes,
  }) => SaleDraftState(
    lines: lines ?? this.lines,
    date: date ?? this.date,
    extraCharges: extraCharges ?? this.extraCharges,
    notes: notes ?? this.notes,
  );
}

class SaleDraft extends Notifier<SaleDraftState> {
  @override
  SaleDraftState build() => const SaleDraftState();

  void addProduct(Product product) {
    state = state.copyWith(
      lines: [...state.lines, DraftSaleLine.forProduct(product)],
    );
  }

  void removeLine(String id) {
    state = state.copyWith(
      lines: state.lines.where((l) => l.id != id).toList(),
    );
  }

  void _updateLine(String id, DraftSaleLine Function(DraftSaleLine) f) {
    state = state.copyWith(
      lines: [for (final l in state.lines) l.id == id ? f(l) : l],
    );
  }

  void setQuantity(String id, int quantity) =>
      _updateLine(id, (l) => l.copyWith(quantity: quantity));

  /// Changing between box and unit resets the price to that suggested price.
  void setPresentation(String id, Presentation presentation) => _updateLine(
    id,
    (l) => l.copyWith(
      presentation: presentation,
      priceText: l.product
          .suggestedPriceFor(presentation)
          .format(symbol: false),
    ),
  );

  void setPrice(String id, String text) =>
      _updateLine(id, (l) => l.copyWith(priceText: text));

  /// Gift toggle: price 0, or back to the suggested price.
  void toggleGift(String id) => _updateLine(
    id,
    (l) => l.copyWith(
      priceText: l.isGift ? l.suggestedPrice.format(symbol: false) : '0',
    ),
  );

  void setDate(DateTime date) => state = state.copyWith(date: date);
  void setNotes(String value) => state = state.copyWith(notes: value);

  /// New extra charge row, optionally with a common concept already filled.
  void addExtraCharge([String concept = '']) => state = state.copyWith(
    extraCharges: [
      ...state.extraCharges,
      DraftExtraCharge(id: newId(), concept: concept),
    ],
  );

  void updateExtraCharge(
    String id, {
    String? concept,
    String? amountText,
    bool? paidByCustomer,
  }) => state = state.copyWith(
    extraCharges: [
      for (final c in state.extraCharges)
        c.id == id
            ? c.copyWith(
                concept: concept,
                amountText: amountText,
                paidByCustomer: paidByCustomer,
              )
            : c,
    ],
  );

  void removeExtraCharge(String id) => state = state.copyWith(
    extraCharges: state.extraCharges.where((c) => c.id != id).toList(),
  );

  void clear() => state = const SaleDraftState();

  /// Registers the sale and empties the cart. Throws a `DomainException`
  /// (cart kept) if the rules reject it, e.g. stock changed meanwhile.
  Future<Sale> submit() async {
    final draft = state;
    final sale = await ref.read(registerSaleProvider)(
      date: draft.date,
      notes: draft.notes.trim().isEmpty ? null : draft.notes.trim(),
      extraCharges: [
        for (final c in draft.filledExtraCharges)
          ExtraChargeInput(
            concept: c.concept,
            amount: c.amount ?? Money.zero,
            paidByCustomer: c.paidByCustomer,
          ),
      ],
      lines: [
        for (final l in draft.lines)
          SaleLineInput(
            productId: l.product.id,
            quantity: l.quantity,
            presentation: l.presentation,
            unitPrice: l.unitPrice!,
          ),
      ],
    );
    clear();
    return sale;
  }
}

final saleDraftProvider = NotifierProvider<SaleDraft, SaleDraftState>(
  SaleDraft.new,
);
