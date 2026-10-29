import 'package:flutter/material.dart';

/// Dark theme for one-handed phone use: big touch targets, rounded fields.
ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7C6CF0),
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF111116),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111116),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1A1A22),
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
      color: const Color(0xFF1A1A22),
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
}
