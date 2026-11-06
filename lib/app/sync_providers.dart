import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/sync/remote_store.dart';
import '../data/sync/supabase_config.dart';
import '../data/sync/sync_service.dart';
import 'providers.dart';

/// Null when this build has no cloud keys: the app is then offline only and
/// nothing below does anything (tests run like that too).
final supabaseClientProvider = Provider<SupabaseClient?>(
  (ref) => SupabaseConfig.isConfigured ? Supabase.instance.client : null,
);

/// Current session, kept on the phone by Supabase: after the first sign-in
/// the app opens without internet too.
final authSessionProvider = StreamProvider<Session?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return Stream.value(null);
  return client.auth.onAuthStateChange
      .map((s) => s.session)
      .startWith(client.auth.currentSession);
});

final syncServiceProvider = Provider<SyncService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  final db = ref.watch(appDatabaseProvider);
  return SyncService(
    db,
    SupabaseRemoteStore(client),
    ref.watch(inventoryReplayerProvider),
  );
});

/// What the sync indicator shows.
class SyncStatus {
  const SyncStatus({
    this.enabled = false,
    this.syncing = false,
    this.pending = 0,
    this.lastSync,
    this.error,
  });

  /// False without cloud keys or without a signed-in user.
  final bool enabled;
  final bool syncing;

  /// Changes made on this phone that the cloud does not have yet.
  final int pending;
  final DateTime? lastSync;

  /// Last failure in Spanish, cleared by the next good round.
  final String? error;

  SyncStatus copyWith({
    bool? syncing,
    int? pending,
    DateTime? lastSync,
    String? error,
    bool clearError = false,
  }) => SyncStatus(
    enabled: enabled,
    syncing: syncing ?? this.syncing,
    pending: pending ?? this.pending,
    lastSync: lastSync ?? this.lastSync,
    error: clearError ? null : (error ?? this.error),
  );
}

/// Runs sync rounds on its own: when the app opens, a moment after each
/// change made here (so a sale reaches the others quickly), every minute to
/// pick up what others did, and on demand. Without connection a round just
/// fails quietly and the next one retries; nothing is lost.
///
/// The minute check only runs while the app is on screen (each one is a few
/// requests to the cloud); coming back to the app syncs right away.
class SyncController extends Notifier<SyncStatus> {
  static const _afterChange = Duration(seconds: 3);
  static const _every = Duration(minutes: 1);

  Timer? _debounce;
  Timer? _periodic;
  Future<void>? _running;

  void _startPeriodic() {
    _periodic?.cancel();
    _periodic = Timer.periodic(_every, (_) => syncNow());
  }

  @override
  SyncStatus build() {
    final service = ref.watch(syncServiceProvider);
    final session = ref.watch(authSessionProvider).value;
    if (service == null || session == null) return const SyncStatus();

    final pendingSub = service.watchPending().listen((n) {
      state = state.copyWith(pending: n);
      if (n > 0) {
        _debounce?.cancel();
        _debounce = Timer(_afterChange, syncNow);
      }
    });
    _startPeriodic();
    final lifecycle = AppLifecycleListener(
      onResume: () {
        _startPeriodic();
        syncNow();
      },
      onHide: () => _periodic?.cancel(),
    );
    Timer.run(syncNow);
    ref.onDispose(() {
      pendingSub.cancel();
      lifecycle.dispose();
      _periodic?.cancel();
      _debounce?.cancel();
    });
    return const SyncStatus(enabled: true);
  }

  /// One round; joins the one in progress instead of starting another.
  Future<void> syncNow() =>
      _running ??= _round().whenComplete(() => _running = null);

  Future<void> _round() async {
    final service = ref.read(syncServiceProvider);
    if (service == null || !state.enabled) return;
    state = state.copyWith(syncing: true);
    try {
      await service.sync();
      state = state.copyWith(
        syncing: false,
        lastSync: DateTime.now(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(syncing: false, error: _describe(e));
    }
  }

  static const _offline = 'Sin conexión. Se reintentará solo.';

  static String _describe(Object e) => switch (e) {
    SocketException() || AuthRetryableFetchException() => _offline,
    PostgrestException(:final message) => 'La nube rechazó un cambio: $message',
    AuthException(:final message) => 'Sesión: $message',
    // The http client wraps socket failures in its own exception type.
    _
        when '$e'.contains('SocketException') ||
            '$e'.contains('ClientException') =>
      _offline,
    _ => 'No se pudo sincronizar: $e',
  };
}

final syncControllerProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);

extension<T> on Stream<T> {
  /// Emits [first] right away, then the stream.
  Stream<T> startWith(T first) async* {
    yield first;
    yield* this;
  }
}
