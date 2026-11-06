import 'package:flutter/material.dart';

/// Dark theme for one-handed phone use: big touch targets, rounded fields.
///
/// Colours come from the logo but stay easy on the eyes: the accent is the
/// ring pink of the logo through Material's tonal palette (a soft, dusty
/// rose, never the saturated pink), and backgrounds are near-neutral dark
/// with a slight warm tint instead of blue-grey.
const brandPink = Color(0xFFD16D69);
const _background = Color(0xFF141213);
const _surface = Color(0xFF1E1A1B);

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: brandPink,
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    // Material's error is a pink almost equal to the accent: use the same
    // red as losses so an error never looks like a button.
    error: const Color(0xFFFF6B6B),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: _background,
    appBarTheme: const AppBarTheme(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _surface,
      indicatorColor: scheme.primaryContainer,
    ),
    // Underline-style borders keep the floating label INSIDE the filled box
    // (an outline border puts it on the top edge).
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: _fieldBorder(BorderSide.none),
      enabledBorder: _fieldBorder(BorderSide.none),
      focusedBorder: _fieldBorder(BorderSide(color: scheme.primary, width: 2)),
      errorBorder: _fieldBorder(BorderSide(color: scheme.error)),
      focusedErrorBorder: _fieldBorder(
        BorderSide(color: scheme.error, width: 2),
      ),
    ),
    chipTheme: const ChipThemeData(showCheckmark: false),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    cardTheme: CardThemeData(
      color: _surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

InputBorder _fieldBorder(BorderSide side) => UnderlineInputBorder(
  borderRadius: BorderRadius.circular(14),
  borderSide: side,
);

/// Semantic colors for money results; reports use the same ones.
extension MoneyColors on ColorScheme {
  Color get gain => const Color(0xFF4CD694);
  Color get loss => const Color(0xFFFF6B6B);

  /// Purchases in the history: money out for stock, neither gain nor loss.
  Color get purchase => const Color(0xFF6EA8FE);
}
