import 'package:supabase_flutter/supabase_flutter.dart';

/// Position reached when downloading one table: the last row seen, ordered
/// by the server's change time and then by id (several rows can share the
/// same instant).
class SyncCursor {
  const SyncCursor({required this.serverUpdatedAt, required this.id});

  /// `2026-11-02T14:00:00.123456Z|<id>`, as kept in `sync_state`.
  factory SyncCursor.parse(String raw) {
    final i = raw.indexOf('|');
    return SyncCursor(
      serverUpdatedAt: raw.substring(0, i),
      id: raw.substring(i + 1),
    );
  }

  /// From a downloaded row; the time is normalized to UTC so cursors compare
  /// the same way whatever offset the server used.
  factory SyncCursor.ofRow(Map<String, Object?> row) => SyncCursor(
    serverUpdatedAt: DateTime.parse(row['server_updated_at']! as String)
        .toUtc()
        .toIso8601String(),
    id: row['id']! as String,
  );

  final String serverUpdatedAt;
  final String id;

  @override
  String toString() => '$serverUpdatedAt|$id';
}

/// The shared database as the sync sees it. Rows are maps with the column
/// names of the tables (snake_case); dates are ISO-8601 text.
abstract interface class RemoteStore {
  /// Inserts or replaces [rows] of [table] by id.
  Future<void> upsert(String table, List<Map<String, Object?>> rows);

  /// Up to [limit] rows of [table] changed after [after] (all when null),
  /// oldest change first. Each row carries `server_updated_at`.
  Future<List<Map<String, Object?>>> changesSince(
    String table, {
    SyncCursor? after,
    required int limit,
  });
}

/// [RemoteStore] backed by Supabase (PostgREST). Access is checked by the
/// row level security of each table: the user must be signed in.
class SupabaseRemoteStore implements RemoteStore {
  SupabaseRemoteStore(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upsert(String table, List<Map<String, Object?>> rows) async {
    if (rows.isEmpty) return;
    await _client.from(table).upsert(rows, onConflict: 'id');
  }

  @override
  Future<List<Map<String, Object?>>> changesSince(
    String table, {
    SyncCursor? after,
    required int limit,
  }) async {
    var query = _client.from(table).select();
    if (after != null) {
      final ts = '"${after.serverUpdatedAt}"';
      query = query.or(
        'server_updated_at.gt.$ts,'
        'and(server_updated_at.eq.$ts,id.gt.${after.id})',
      );
    }
    final rows = await query
        .order('server_updated_at', ascending: true)
        .order('id', ascending: true)
        .limit(limit);
    return rows;
  }
}
