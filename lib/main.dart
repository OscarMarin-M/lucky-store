import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/shell/home_shell.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: LuckyStoreApp()));
}

class LuckyStoreApp extends StatelessWidget {
  const LuckyStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = buildDarkTheme();
    return MaterialApp(
      title: 'Lucky Store',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      home: const HomeShell(),
    );
  }
}
