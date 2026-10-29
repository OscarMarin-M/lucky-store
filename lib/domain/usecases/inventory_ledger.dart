import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/money/unit_cost.dart';
import '../../core/quantity/presentation.dart';
import '../costing/cost_strategy.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Business parameters that change how inventory behaves.
class InventoryPolicy {
  const InventoryPolicy({this.allowNegativeStock = false});

  /// When false (default) selling or writing off more than the stock fails.
  final bool allowNegativeStock;
}

class PurchaseEffect {
  const PurchaseEffect({required this.unitsBase, required this.unitCost});

  final int unitsBase;
  final UnitCost unitCost;
}

class OutflowEffect {
  const OutflowEffect({
    required this.unitsBase,
    required this.unitCost,
    required this.totalCost,
  });

  final int unitsBase;
  final UnitCost unitCost;
  final Money totalCost;
}

/// Working copy of the products touched by one document (purchase, sale or
/// adjustment). Several lines of the same product see each other's effect,
/// and nothing is written until [flush], so a failing line leaves no trace.
class InventoryLedger {
  InventoryLedger(this._products, this._strategy, this._policy);

  final ProductRepository _products;
  final CostStrategy _strategy;
  final InventoryPolicy _policy;
  final Map<String, Product> _working = {};
  final Set<String> _touched = {};

  Future<Product> product(String id) async {
    final cached = _working[id];
    if (cached != null) return cached;
    final loaded = await _products.getById(id);
    if (loaded == null) throw EntityNotFoundException('Producto', id);
    return _working[id] = loaded;
  }

  Future<PurchaseEffect> purchase(
    String productId, {
    required int quantity,
    required Presentation presentation,
    required Money total,
  }) async {
    final product = await this.product(productId);
    final units = toBaseUnits(
      quantity: quantity,
      presentation: presentation,
      unitsPerBox: product.unitsPerBox,
    );
    final state = _strategy.applyPurchase(
      product.stockState,
      units: units,
      total: total,
    );
    _apply(product, state);
    return PurchaseEffect(
      unitsBase: units,
      unitCost: UnitCost.fromTotal(total, units),
    );
  }

  Future<OutflowEffect> outflow(
    String productId, {
    required int quantity,
    required Presentation presentation,
  }) async {
    final product = await this.product(productId);
    final units = toBaseUnits(
      quantity: quantity,
      presentation: presentation,
      unitsPerBox: product.unitsPerBox,
    );
    final result = _strategy.applyOutflow(
      product.stockState,
      units: units,
      allowNegativeStock: _policy.allowNegativeStock,
    );
    _apply(product, result.newState);
    return OutflowEffect(
      unitsBase: units,
      unitCost: result.unitCost,
      totalCost: result.totalCost,
    );
  }

  void _apply(Product product, StockState state) {
    _working[product.id] = product.copyWith(
      stockUnits: state.units,
      avgCost: state.avgCost,
    );
    _touched.add(product.id);
  }

  /// Persists the new stock/cost of every touched product.
  Future<void> flush() async {
    for (final id in _touched) {
      final p = _working[id]!;
      await _products.updateInventory(
        id,
        stockUnits: p.stockUnits,
        avgCost: p.avgCost,
      );
    }
  }
}
