/// Typed business-rule violations. The UI can switch on these.
sealed class DomainException implements Exception {
  const DomainException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class InvalidQuantityException extends DomainException {
  const InvalidQuantityException(int quantity)
      : super('La cantidad debe ser mayor a 0 (recibido: $quantity)');
}

class InvalidUnitsPerBoxException extends DomainException {
  const InvalidUnitsPerBoxException(int unitsPerBox)
      : super('unidades_por_caja debe ser >= 1 (recibido: $unitsPerBox)');
}

class InvalidAmountException extends DomainException {
  const InvalidAmountException(String message) : super(message);
}

class InsufficientStockException extends DomainException {
  InsufficientStockException({
    required this.available,
    required this.requested,
  }) : super('Stock insuficiente: disponible $available, solicitado $requested');

  final int available;
  final int requested;
}

class EntityNotFoundException extends DomainException {
  EntityNotFoundException(String entity, String id)
      : super('$entity no encontrado: $id');
}

class EmptyDocumentException extends DomainException {
  const EmptyDocumentException()
      : super('El documento debe tener al menos una línea');
}
