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
    Clock clock = DateTime.now,
  }) {
    if (unitsPerBox < 1) throw InvalidUnitsPerBoxException(unitsPerBox);
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

  final bool isActive;

  StockState get stockState => StockState(units: stockUnits, avgCost: avgCost);

  /// Value of the inventory at average cost.
  Money get stockValue => avgCost.totalFor(stockUnits);

  /// Suggested price for one [presentation]; the sale can override it.
  Money suggestedPriceFor(Presentation presentation) => switch (presentation) {
        Presentation.unit => suggestedPriceUnit,
        Presentation.box =>
          suggestedPriceBox ?? suggestedPriceUnit.times(unitsPerBox),
      };

  /// Edits the catalog data of the product (what a form changes). Unlike
  /// [copyWith], null [sku] / [suggestedPriceBox] really clear the field.
  /// Stock and average cost are untouched: only purchases, sales and
  /// adjustments move them.
  Product withDetails({
    required String name,
    String? sku,
    required int unitsPerBox,
    required Money suggestedPriceUnit,
    Money? suggestedPriceBox,
    required bool isActive,
  }) {
    if (unitsPerBox < 1) throw InvalidUnitsPerBoxException(unitsPerBox);
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
    bool? isActive,
  }) {
    if (unitsPerBox != null && unitsPerBox < 1) {
      throw InvalidUnitsPerBoxException(unitsPerBox);
    }
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
      isActive: isActive ?? this.isActive,
    );
  }
}
