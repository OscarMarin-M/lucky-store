import '../../core/errors/domain_exception.dart';
import '../../core/money/money.dart';

/// Form validator for Bs amounts typed by the user (`12`, `12,5`, `12.50`).
String? validateMoney(String? value, {required bool required}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return required ? 'Obligatorio' : null;
  try {
    if (Money.parse(text).isNegative) return 'No puede ser negativo';
    return null;
  } on DomainException {
    return 'Usa un monto como 12,50 (máx. 2 decimales)';
  }
}

/// Parses [text] as money, or null when it is empty/invalid.
Money? tryParseMoney(String text) {
  try {
    return Money.parse(text);
  } on DomainException {
    return null;
  }
}
