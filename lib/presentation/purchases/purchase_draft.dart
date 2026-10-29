import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../core/quantity/presentation.dart';
import '../../core/util/clock.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/usecases/register_purchase.dart';
import '../common/validators.dart';

/// One line being typed. The user enters the price of ONE box (or unit);
/// the line total and what each unit comes out at are derived from it.
/// [priceText] stays raw so the field keeps exactly what the user wrote.
class DraftPurchaseLine {
  const DraftPurchaseLine({
    required this.id,
    required this.product,
    required this.quantity,
    required this.presentation,
    this.priceText = '',
  });

  /// Starts in boxes when the product has them: that is how stock is bought.
  factory DraftPurchaseLine.forProduct(Product product) => DraftPurchaseLine(
    id: newId(),
    product: product,
    quantity: 1,
    presentation: product.unitsPerBox > 1
        ? Presentation.box
        : Presentation.unit,
  );

  final String id;
  final Product product;
  final int quantity;
  final Presentation presentation;

  /// Price paid per [presentation] (one box or one unit), as typed.
  final String priceText;

  Money? get price => tryParseMoney(priceText);

  /// `price x quantity`: exact, integer centavos.
  Money? get lineTotal => quantity < 1 ? null : price?.times(quantity);

  /// What each base unit comes out at ("sale a").
  UnitCost? get unitCost {
    final total = lineTotal;
    final units = unitsBase;
    if (total == null || units == null || total.isNegative) return null;
    return UnitCost.fromTotal(total, units);
  }

  /// Quantity in base units, or null while the quantity is invalid.
  int? get unitsBase => quantity < 1
      ? null
      : toBaseUnits(
          quantity: quantity,
          presentation: presentation,
          unitsPerBox: product.unitsPerBox,
        );

  bool get isValid {
    final p = price;
    return quantity >= 1 && p != null && !p.isNegative;
  }

  DraftPurchaseLine copyWith({
    int? quantity,
    Presentation? presentation,
    String? priceText,
  }) => DraftPurchaseLine(
    id: id,
    product: product,
    quantity: quantity ?? this.quantity,
    presentation: presentation ?? this.presentation,
    priceText: priceText ?? this.priceText,
  );
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

  void _updateLine(String id, DraftPurchaseLine Function(DraftPurchaseLine) f) {
    state = state.copyWith(
      lines: [for (final l in state.lines) l.id == id ? f(l) : l],
    );
  }

  void setQuantity(String id, int quantity) =>
      _updateLine(id, (l) => l.copyWith(quantity: quantity));

  /// The typed price meant "per box" or "per unit": switching clears it so a
  /// unit price is never registered as a box price by accident.
  void setPresentation(String id, Presentation presentation) => _updateLine(
    id,
    (l) => l.presentation == presentation
        ? l
        : l.copyWith(presentation: presentation, priceText: ''),
  );

  void setPrice(String id, String text) =>
      _updateLine(id, (l) => l.copyWith(priceText: text));

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
          PurchaseLineInput(
            productId: l.product.id,
            quantity: l.quantity,
            presentation: l.presentation,
            lineTotal: l.lineTotal!,
          ),
      ],
    );
    clear();
    return purchase;
  }
}

final purchaseDraftProvider =
    NotifierProvider<PurchaseDraft, PurchaseDraftState>(PurchaseDraft.new);
