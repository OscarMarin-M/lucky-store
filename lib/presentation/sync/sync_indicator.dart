import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/sync_providers.dart';
import '../format/date_format.dart';

/// Cloud icon for the app bar: synced, changes waiting, syncing or offline.
/// Tapping it opens the account sheet. Invisible in builds without cloud.
/// Watching the controller here is also what keeps the automatic sync alive.
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncControllerProvider);
    if (!status.enabled) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    final Widget icon;
    if (status.syncing) {
      icon = const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (status.error != null) {
      icon = Icon(Icons.cloud_off_outlined, color: scheme.tertiary);
    } else if (status.pending > 0) {
      icon = Badge.count(
        count: status.pending,
        child: const Icon(Icons.cloud_upload_outlined),
      );
    } else {
      icon = const Icon(Icons.cloud_done_outlined);
    }
    return IconButton(
      tooltip: 'Sincronización',
      icon: icon,
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => const _SyncSheet(),
      ),
    );
  }
}

class _SyncSheet extends ConsumerWidget {
  const _SyncSheet();

  /// `Todo sincronizado · 14:05`, `3 cambios por subir`...
  static String _summary(SyncStatus s) {
    if (s.syncing) return 'Sincronizando…';
    final pending = switch (s.pending) {
      0 => null,
      1 => '1 cambio por subir',
      final n => '$n cambios por subir',
    };
    if (s.error != null) return pending ?? 'No se pudo sincronizar';
    if (pending != null) return pending;
    final last = s.lastSync;
    return last == null
        ? 'Todo sincronizado'
        : 'Todo sincronizado · ${formatTime(last)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = ref.watch(syncControllerProvider);
    final email = ref.watch(authSessionProvider).value?.user.email;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(email ?? 'Sesión iniciada'),
              subtitle: Text(_summary(status)),
            ),
            if (status.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  status.error!,
                  style: TextStyle(color: theme.colorScheme.tertiary),
                ),
              ),
            Text(
              'Todo se guarda primero en este teléfono; sin internet sigue '
              'funcionando y se sube cuando vuelva la conexión.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: status.syncing
                  ? null
                  : () => ref.read(syncControllerProvider.notifier).syncNow(),
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar ahora'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _signOut(context, ref, status.pending),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  /// Data stays on the phone; with pending changes it asks first, because
  /// they will not go up until someone signs in again.
  Future<void> _signOut(
    BuildContext context,
    WidgetRef ref,
    int pending,
  ) async {
    if (pending > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Hay cambios sin subir'),
          content: Text(
            '$pending ${pending == 1 ? 'cambio no se subió' : 'cambios no se subieron'} '
            'todavía. Se subirán cuando vuelvas a iniciar sesión.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (context.mounted) Navigator.of(context).pop();
    await ref.read(supabaseClientProvider)?.auth.signOut();
  }
}
