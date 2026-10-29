/// Integer division rounding half away from zero (2.5 -> 3, -2.5 -> -3).
///
/// Single place where rounding rules live, so money/cost math never touches
/// floating point.
int divRound(int numerator, int denominator) {
  if (denominator <= 0) {
    throw ArgumentError.value(denominator, 'denominator', 'must be > 0');
  }
  final sign = numerator < 0 ? -1 : 1;
  final abs = numerator.abs();
  return sign * ((abs * 2 + denominator) ~/ (2 * denominator));
}
