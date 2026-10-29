import '../../core/money/unit_cost.dart';
import '../entities/product.dart';
import 'crud_repository.dart';

abstract interface class ProductRepository implements CrudRepository<Product> {
  /// Products whose name or SKU contains [query] (case-insensitive).
  Future<List<Product>> search(String query);

  /// Writes the inventory position computed by a purchase/sale/adjustment.
  /// Only the use cases should call this; the UI edits products via `update`.
  Future<void> updateInventory(
    String productId, {
    required int stockUnits,
    required UnitCost avgCost,
  });
}
