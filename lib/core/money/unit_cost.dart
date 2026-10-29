import '../util/int_math.dart';
import 'money.dart';

/// Cost of one base unit with 4 decimals of precision (1/10.000 Bs).
///
/// A box of 24 bought at Bs 50,00 costs Bs 2,0833 per unit; rounding that to
/// centavos would drift the profit of big boxes, so costs keep 2 extra digits
/// and are only rounded to centavos when turned into a [Money] total.
final class UnitCost implements Comparable<UnitCost> {
  const UnitCost(this.raw);

  static const zero = UnitCost(0);

  /// Raw units per Bs (4 decimals).
  static const scale = 10000;

  /// Raw units per centavo.
  static const rawPerCent = scale ~/ 100;

  /// Value in 1/10.000 Bs.
  final int raw;

  /// Cost per unit of paying [total] for [units] base units.
  factory UnitCost.fromTotal(Money total, int units) =>
      UnitCost(divRound(total.cents * rawPerCent, units));

  /// Total cost of [units], rounded half-up to centavos.
  Money totalFor(int units) => Money(divRound(raw * units, rawPerCent));

  /// Unrounded total in raw units (used by the weighted average).
  int rawTotalFor(int units) => raw * units;

  @override
  int compareTo(UnitCost other) => raw.compareTo(other.raw);

  /// `Bs 2,0833`
  String format({bool symbol = true}) {
    final abs = raw.abs();
    final text = '${abs ~/ scale},${(abs % scale).toString().padLeft(4, '0')}';
    final signed = raw < 0 ? '-$text' : text;
    return symbol ? 'Bs $signed' : signed;
  }

  @override
  bool operator ==(Object other) => other is UnitCost && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => 'UnitCost($raw)';
}
