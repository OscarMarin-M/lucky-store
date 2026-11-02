import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/sync/supabase_config.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/shell/home_shell.dart';
import 'presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Offline-first: the local database is always the one the app uses; the
  // cloud is only connected when this build carries its keys.
  await SupabaseConfig.initialize();
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
      home: const AuthGate(child: HomeShell()),
    );
  }
}
