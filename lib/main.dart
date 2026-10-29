import 'package:flutter/material.dart';

void main() {
  runApp(const LuckyStoreApp());
}

/// Entry point placeholder: screens live in `presentation/` and are built later.
class LuckyStoreApp extends StatelessWidget {
  const LuckyStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Lucky Store',
      home: Scaffold(),
    );
  }
}
