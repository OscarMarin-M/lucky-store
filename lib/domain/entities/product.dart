import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../core/quantity/presentation.dart';
import '../../core/util/clock.dart';
import '../costing/cost_strategy.dart';
import 'base_entity.dart';

class Product extends BaseEntity {
  const Product({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.name,
    this.sku,
    this.unitsPerBox = 1,
    this.stockUnits = 0,
    this.avgCost = UnitCost.zero,
    this.suggestedPriceUnit = Money.zero,
    this.suggestedPriceBox,
    this.unitsPerBag,
    this.suggestedPriceBag,
    this.minStockUnits,
    this.isActive = true,
  });

  /// New product with generated id and timestamps. Stock and cost start at 0
  /// and are only changed by purchases/sales/adjustments.
  factory Product.create({
    required String name,
    String? sku,
    int unitsPerBox = 1,
    Money suggestedPriceUnit = Money.zero,
    Money? suggestedPriceBox,
    int? unitsPerBag,
    Money? suggestedPriceBag,
    int? minStockUnits,
    Clock clock = DateTime.now,
  }) {
    _checkSizes(unitsPerBox, unitsPerBag);
    final now = clock();
    return Product(
      id: newId(),
      createdAt: now,
      updatedAt: now,
      name: name,
      sku: sku,
      unitsPerBox: unitsPerBox,
      suggestedPriceUnit: suggestedPriceUnit,
      suggestedPriceBox: suggestedPriceBox,
      unitsPerBag: unitsPerBag,
      suggestedPriceBag: suggestedPriceBag,
      minStockUnits: minStockUnits,
    );
  }

  final String name;
  final String? sku;

  /// Base units in one box (1 for products sold without boxes).
  final int unitsPerBox;

  /// Current inventory in base units.
  final int stockUnits;

  /// Current weighted average cost per base unit.
  final UnitCost avgCost;

  final Money suggestedPriceUnit;

  /// Suggested price of a whole box; when null it is units x unit price.
  final Money? suggestedPriceBox;

  /// v10. Base units in one bag; null = the product does not come in bags
  /// (then "Bolsa" is not offered when selling or writing off). Like the box
  /// size it is only a default: each purchased bag lot keeps its own size.
  final int? unitsPerBag;

  /// Suggested price of a whole bag; when null it is units x unit price.
  final Money? suggestedPriceBag;

  /// At or below this many base units the product shows as "stock bajo" in
  /// Inicio. Null = no alert for this product.
  final int? minStockUnits;

  final bool isActive;

  StockState get stockState => StockState(units: stockUnits, avgCost: avgCost);

  /// Value of the inventory at average cost.
  Money get stockValue => avgCost.totalFor(stockUnits);

  /// Never true for a product without a minimum.
  bool get isLowStock {
    final min = minStockUnits;
    return min != null && stockUnits <= min;
  }

  bool get hasBoxes => unitsPerBox > 1;
  bool get hasBags => unitsPerBag != null;

  /// What a sale or write-off of this product can be counted in.
  List<Presentation> get presentations => [
        Presentation.unit,
        if (hasBoxes) Presentation.box,
        if (hasBags) Presentation.bag,
      ];

  /// Base units in one [presentation] by default (null: no bags).
  int? unitsIn(Presentation presentation) => switch (presentation) {
        Presentation.unit => 1,
        Presentation.box => unitsPerBox,
        Presentation.bag => unitsPerBag,
      };

  /// [quantity] of [presentation] in base units, with this product's sizes.
  int toBase(int quantity, Presentation presentation) => toBaseUnits(
        quantity: quantity,
        presentation: presentation,
        unitsPerBox: unitsPerBox,
        unitsPerBag: unitsPerBag,
      );

  /// Suggested price for one [presentation]; the sale can override it.
  Money suggestedPriceFor(Presentation presentation) => switch (presentation) {
        Presentation.unit => suggestedPriceUnit,
        Presentation.box =>
          suggestedPriceBox ?? suggestedPriceUnit.times(unitsPerBox),
        Presentation.bag =>
          suggestedPriceBag ?? suggestedPriceUnit.times(unitsPerBag ?? 1),
      };

  /// Edits the catalog data of the product (what a form changes). Unlike
  /// [copyWith], null [sku] / [suggestedPriceBox] / [unitsPerBag] /
  /// [suggestedPriceBag] really clear the field.
  /// Stock and average cost are untouched: only purchases, sales and
  /// adjustments move them.
  Product withDetails({
    required String name,
    String? sku,
    required int unitsPerBox,
    required Money suggestedPriceUnit,
    Money? suggestedPriceBox,
    int? unitsPerBag,
    Money? suggestedPriceBag,
    int? minStockUnits,
    required bool isActive,
  }) {
    _checkSizes(unitsPerBox, unitsPerBag);
    return Product(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      name: name,
      sku: sku,
      unitsPerBox: unitsPerBox,
      stockUnits: stockUnits,
      avgCost: avgCost,
      suggestedPriceUnit: suggestedPriceUnit,
      suggestedPriceBox: suggestedPriceBox,
      unitsPerBag: unitsPerBag,
      suggestedPriceBag: suggestedPriceBag,
      minStockUnits: minStockUnits,
      isActive: isActive,
    );
  }

  Product copyWith({
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? name,
    String? sku,
    int? unitsPerBox,
    int? stockUnits,
    UnitCost? avgCost,
    Money? suggestedPriceUnit,
    Money? suggestedPriceBox,
    int? unitsPerBag,
    Money? suggestedPriceBag,
    int? minStockUnits,
    bool? isActive,
  }) {
    _checkSizes(unitsPerBox ?? this.unitsPerBox, unitsPerBag);
    return Product(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      unitsPerBox: unitsPerBox ?? this.unitsPerBox,
      stockUnits: stockUnits ?? this.stockUnits,
      avgCost: avgCost ?? this.avgCost,
      suggestedPriceUnit: suggestedPriceUnit ?? this.suggestedPriceUnit,
      suggestedPriceBox: suggestedPriceBox ?? this.suggestedPriceBox,
      unitsPerBag: unitsPerBag ?? this.unitsPerBag,
      suggestedPriceBag: suggestedPriceBag ?? this.suggestedPriceBag,
      minStockUnits: minStockUnits ?? this.minStockUnits,
      isActive: isActive ?? this.isActive,
    );
  }
}

void _checkSizes(int unitsPerBox, int? unitsPerBag) {
  if (unitsPerBox < 1) throw InvalidUnitsPerBoxException(unitsPerBox);
  if (unitsPerBag != null && unitsPerBag < 1) {
    throw InvalidUnitsPerBagException(unitsPerBag);
  }
}
