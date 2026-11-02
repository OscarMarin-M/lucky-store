import 'package:supabase_flutter/supabase_flutter.dart';

/// Where the shared database lives. The values come from
/// `--dart-define-from-file=env/dev.json` (not committed, see
/// env/example.json); without them the app works offline only, as before,
/// which also keeps tests and plain `flutter run` working.
class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');

  /// Publishable key: meant to ship inside the app. Data is protected by the
  /// row level security of each table and by signing in, not by this key.
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  /// Connects to Supabase when configured; true if it did.
  static Future<bool> initialize() async {
    if (!isConfigured) return false;
    await Supabase.initialize(url: url, publishableKey: publishableKey);
    return true;
  }
}
