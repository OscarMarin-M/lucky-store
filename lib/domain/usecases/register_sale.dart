import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';
import '../../core/quantity/presentation.dart';
import '../../core/util/clock.dart';
import '../../core/util/current_user.dart';
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

/// An amount of the order that is not a product, paid by the customer or by
/// the shop (see `SaleExtraCharge`).
class ExtraChargeInput {
  const ExtraChargeInput({
    required this.concept,
    required this.amount,
    this.paidByCustomer = true,
  });

  final String concept;
  final Money amount;
  final bool paidByCustomer;

  void validate() {
    if (concept.trim().isEmpty) {
      throw const InvalidAmountException(
        'Cada cargo adicional necesita un concepto',
      );
    }
    if (amount.cents <= 0) {
      throw InvalidAmountException(
        'El cargo adicional "${concept.trim()}" debe ser mayor a 0',
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
    CurrentUser currentUser = noUser,
  })  : _products = products,
        _sales = sales,
        _transactions = transactions,
        _strategy = costStrategy,
        _policy = policy,
        _clock = clock,
        _currentUser = currentUser;

  final ProductRepository _products;
  final SaleRepository _sales;
  final TransactionRunner _transactions;
  final CostStrategy _strategy;
  final InventoryPolicy _policy;
  final Clock _clock;
  final CurrentUser _currentUser;

  Future<Sale> call({
    DateTime? date,
    String? notes,
    required List<SaleLineInput> lines,
    List<ExtraChargeInput> extraCharges = const [],
  }) {
    if (lines.isEmpty) throw const EmptyDocumentException();
    for (final c in extraCharges) {
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
        for (final c in extraCharges)
          SaleExtraCharge(
            id: newId(),
            createdAt: now,
            updatedAt: now,
            saleId: saleId,
            concept: c.concept.trim(),
            amount: c.amount,
            paidByCustomer: c.paidByCustomer,
          ),
      ];
      final sale = await _sales.save(Sale(
        id: saleId,
        createdAt: now,
        updatedAt: now,
        date: date ?? now,
        notes: notes,
        registeredBy: _currentUser(),
        // A charge to the customer raises what is collected and the profit;
        // a cost the shop absorbs only lowers the profit. Neither touches
        // stock.
        total: built.map((l) => l.lineTotal).sum +
            extras.map((c) => c.totalEffect).sum,
        profit: built.map((l) => l.profit).sum +
            extras.map((c) => c.profitEffect).sum,
        lines: built,
        extraCharges: extras,
      ));
      await ledger.flush();
      return sale;
    });
  }
}
