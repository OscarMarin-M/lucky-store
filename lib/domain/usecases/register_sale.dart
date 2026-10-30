import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/quantity/presentation.dart';
import '../../core/util/clock.dart';
import '../costing/cost_strategy.dart';
import '../entities/sale.dart';
import '../repositories/document_repositories.dart';
import '../repositories/product_repository.dart';
import 'inventory_ledger.dart';

class SaleLineInput {
  const SaleLineInput({
    required this.productId,
    required this.quantity,
    required this.presentation,
    this.unitPrice,
  });

  final String productId;
  final int quantity;
  final Presentation presentation;

  /// Price charged per [presentation] (one box or one unit). When null the
  /// product's suggested price is used.
  final Money? unitPrice;
}

/// A cost of the order that is not a product (see `SaleExtraCost`).
class ExtraCostInput {
  const ExtraCostInput({required this.concept, required this.amount});

  final String concept;
  final Money amount;

  void validate() {
    if (concept.trim().isEmpty) {
      throw const InvalidAmountException(
        'Cada costo adicional necesita un concepto',
      );
    }
    if (amount.cents <= 0) {
      throw InvalidAmountException(
        'El costo adicional "${concept.trim()}" debe ser mayor a 0',
      );
    }
  }
}

/// Registers a sale: freezes price, suggested price, cost and profit on each
/// line and lowers stock, atomically. Fails if there is not enough stock
/// (unless the policy allows negative stock).
class RegisterSale {
  RegisterSale({
    required ProductRepository products,
    required SaleRepository sales,
    required TransactionRunner transactions,
    required CostStrategy costStrategy,
    InventoryPolicy policy = const InventoryPolicy(),
    Clock clock = DateTime.now,
  })  : _products = products,
        _sales = sales,
        _transactions = transactions,
        _strategy = costStrategy,
        _policy = policy,
        _clock = clock;

  final ProductRepository _products;
  final SaleRepository _sales;
  final TransactionRunner _transactions;
  final CostStrategy _strategy;
  final InventoryPolicy _policy;
  final Clock _clock;

  Future<Sale> call({
    DateTime? date,
    String? notes,
    required List<SaleLineInput> lines,
    List<ExtraCostInput> extraCosts = const [],
  }) {
    if (lines.isEmpty) throw const EmptyDocumentException();
    for (final c in extraCosts) {
      c.validate();
    }

    return _transactions.run(() async {
      final now = _clock();
      final saleId = newId();
      final ledger = InventoryLedger(_products, _strategy, _policy);

      final built = <SaleLine>[];
      for (final input in lines) {
        final product = await ledger.product(input.productId);
        final suggested = product.suggestedPriceFor(input.presentation);
        final price = input.unitPrice ?? suggested;
        if (price.isNegative) {
          throw const InvalidAmountException('El precio no puede ser negativo');
        }

        final effect = await ledger.outflow(
          input.productId,
          quantity: input.quantity,
          presentation: input.presentation,
        );
        final lineTotal = price.times(input.quantity);
        built.add(SaleLine(
          id: newId(),
          createdAt: now,
          updatedAt: now,
          saleId: saleId,
          productId: input.productId,
          quantity: input.quantity,
          presentation: input.presentation,
          unitsBase: effect.unitsBase,
          unitPrice: price,
          suggestedUnitPrice: suggested,
          lineTotal: lineTotal,
          costAtSale: effect.unitCost,
          costTotal: effect.totalCost,
          profit: lineTotal - effect.totalCost,
        ));
      }

      final extras = [
        for (final c in extraCosts)
          SaleExtraCost(
            id: newId(),
            createdAt: now,
            updatedAt: now,
            saleId: saleId,
            concept: c.concept.trim(),
            amount: c.amount,
          ),
      ];
      final sale = await _sales.save(Sale(
        id: saleId,
        createdAt: now,
        updatedAt: now,
        date: date ?? now,
        notes: notes,
        total: built.map((l) => l.lineTotal).sum,
        profit: built.map((l) => l.profit).sum -
            extras.map((c) => c.amount).sum,
        lines: built,
        extraCosts: extras,
      ));
      await ledger.flush();
      return sale;
    });
  }
}
