import '../errors/domain_exception.dart';

/// Amount in Bolivianos stored as integer centavos (max 2 decimals).
///
/// `Money(1250)` is Bs 12,50. No floating point anywhere.
final class Money implements Comparable<Money> {
  const Money(this.cents);

  static const zero = Money(0);

  final int cents;

  static final _pattern = RegExp(r'^(-?)(\d+)(?:[.,](\d{1,2}))?$');

  /// Parses user input like `12`, `12.5`, `12,50`. More than 2 decimals is
  /// rejected instead of silently rounded.
  factory Money.parse(String input) {
    final match = _pattern.firstMatch(input.trim());
    if (match == null) {
      throw InvalidAmountException('Monto inválido: "$input"');
    }
    final negative = match.group(1) == '-';
    final whole = int.parse(match.group(2)!);
    final decimals = (match.group(3) ?? '').padRight(2, '0');
    final cents = whole * 100 + int.parse(decimals);
    return Money(negative ? -cents : cents);
  }

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  Money operator -() => Money(-cents);

  /// Multiplies by a whole quantity.
  Money times(int factor) => Money(cents * factor);

  bool get isNegative => cents < 0;
  bool get isZero => cents == 0;

  bool operator <(Money other) => cents < other.cents;
  bool operator <=(Money other) => cents <= other.cents;
  bool operator >(Money other) => cents > other.cents;
  bool operator >=(Money other) => cents >= other.cents;

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  /// `Bs 12,50`, `-Bs 12,50` (or `12,50` / `-12,50` with [symbol] false).
  String format({bool symbol = true}) {
    final abs = cents.abs();
    final text = '${abs ~/ 100},${(abs % 100).toString().padLeft(2, '0')}';
    final withSymbol = symbol ? 'Bs $text' : text;
    return cents < 0 ? '-$withSymbol' : withSymbol;
  }

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => 'Money($cents)';
}

extension MoneyIterableSum on Iterable<Money> {
  Money get sum => fold(Money.zero, (a, b) => a + b);
}
