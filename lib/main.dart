import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: LuckyStoreApp()));
}

/// Entry point placeholder: screens live in `presentation/` and are built later.
class LuckyStoreApp extends StatelessWidget {
  const LuckyStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucky Store',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const Scaffold(),
    );
  }
}
