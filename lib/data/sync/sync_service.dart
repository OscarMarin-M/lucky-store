import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'inventory_rebuilder.dart';
import 'remote_store.dart';
import 'synced_tables.dart';

/// What one sync round did.
class SyncResult {
  const SyncResult({required this.pushed, required this.pulled});

  final int pushed;
  final int pulled;
}

/// Offline-first sync between this phone's database and the cloud.
///
/// The phone always works on its own database. A round first uploads what
/// the outbox holds (rows written here, see `sync.drift`), then downloads
/// what other phones wrote since the last round and replays the inventory.
/// Rows are only upserted by id and nothing is hard-deleted, so repeating a
/// round (after a lost connection, for example) is harmless.
class SyncService {
  SyncService(this._db, this._remote, this._rebuilder, {this.pageSize = 500});

  final AppDatabase _db;
  final RemoteStore _remote;
  final InventoryRebuilder _rebuilder;
  final int pageSize;

  static const _applyingRemote = 'applying_remote';
  static String _cursorKey(String table) => 'cursor:$table';

  Future<SyncResult> sync() async {
    final pushed = await push();
    final pulled = await pull();
    return SyncResult(pushed: pushed, pulled: pulled);
  }

  /// Rows waiting in the outbox.
  Stream<int> watchPending() {
    final count = _db.syncOutbox.seq.count();
    return (_db.selectOnly(_db.syncOutbox)..addColumns([count]))
        .map((r) => r.read(count) ?? 0)
        .watchSingle();
  }

  /// Uploads the outbox, parents first. Entries are removed only after the
  /// cloud accepted them; a row edited again meanwhile has a newer entry
  /// and goes up in the next round.
  Future<int> push() async {
    final entries = await (_db.select(
      _db.syncOutbox,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    if (entries.isEmpty) return 0;

    final idsByTable = <String, Set<String>>{};
    for (final e in entries) {
      idsByTable.putIfAbsent(e.tableName$, () => {}).add(e.rowId);
    }
    var pushed = 0;
    for (final table in syncedTableNames) {
      final ids = idsByTable[table]?.toList() ?? const <String>[];
      for (var i = 0; i < ids.length; i += pageSize) {
        final chunk = ids.sublist(i, (i + pageSize).clamp(0, ids.length));
        final rows = await _db.customSelect(
          'SELECT * FROM $table WHERE id IN '
          '(${List.filled(chunk.length, '?').join(', ')})',
          variables: [for (final id in chunk) Variable<String>(id)],
        ).get();
        await _remote.upsert(table, [
          for (final r in rows) _toRemote(table, r.data),
        ]);
        pushed += rows.length;
      }
    }
    final lastSeq = entries.last.seq;
    await (_db.delete(
      _db.syncOutbox,
    )..where((t) => t.seq.isSmallerOrEqualValue(lastSeq))).go();
    return pushed;
  }

  /// Downloads every table since its cursor and applies it in one
  /// transaction together with the new cursors: if anything fails (e.g. a
  /// line arrived before its document) nothing is kept and the next round
  /// tries again from the same place.
  Future<int> pull() async {
    final downloaded = <String, List<Map<String, Object?>>>{};
    final cursors = <String, SyncCursor>{};
    for (final table in syncedTableNames) {
      var cursor = await _readCursor(table);
      final rows = <Map<String, Object?>>[];
      while (true) {
        final page = await _remote.changesSince(
          table,
          after: cursor,
          limit: pageSize,
        );
        rows.addAll(page);
        if (page.isNotEmpty) cursor = SyncCursor.ofRow(page.last);
        if (page.length < pageSize) break;
      }
      if (rows.isEmpty) continue;
      downloaded[table] = rows;
      cursors[table] = cursor!;
    }
    if (downloaded.isEmpty) return 0;

    var applied = 0;
    await _db.transaction(() async {
      // Parents and children of this batch may come in any order.
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      await _db
          .into(_db.syncState)
          .insertOnConflictUpdate(
            SyncStateCompanion.insert(key: _applyingRemote),
          );
      // A row changed here and not uploaded yet keeps the local version;
      // the next push sends it.
      final pending = <String>{
        for (final e in await _db.select(_db.syncOutbox).get())
          '${e.tableName$}/${e.rowId}',
      };
      for (final table in syncedTableNames) {
        for (final row in downloaded[table] ?? const []) {
          if (pending.contains('$table/${row['id']}')) continue;
          await _upsertLocal(table, row);
          applied++;
        }
        final cursor = cursors[table];
        if (cursor != null) {
          await _db
              .into(_db.syncState)
              .insertOnConflictUpdate(
                SyncStateCompanion.insert(
                  key: _cursorKey(table),
                  value: Value(cursor.toString()),
                ),
              );
        }
      }
      await (_db.delete(
        _db.syncState,
      )..where((t) => t.key.equals(_applyingRemote))).go();
      await _rebuilder.rebuild();
    });
    return applied;
  }

  Future<SyncCursor?> _readCursor(String table) async {
    final row = await (_db.select(
      _db.syncState,
    )..where((t) => t.key.equals(_cursorKey(table)))).getSingleOrNull();
    return row?.value == null ? null : SyncCursor.parse(row!.value!);
  }

  TableInfo _table(String name) =>
      _db.allTables.firstWhere((t) => t.actualTableName == name);

  Iterable<GeneratedColumn> _syncedColumns(String table) {
    final skip = localOnlyColumns[table] ?? const <String>{};
    return _table(table).$columns.where((c) => !skip.contains(c.name));
  }

  /// Local raw row -> cloud row: dates as UTC ISO text, booleans as bools.
  Map<String, Object?> _toRemote(String table, Map<String, Object?> data) => {
    for (final c in _syncedColumns(table))
      c.name: switch ((c.type, data[c.name])) {
        (_, null) => null,
        (DriftSqlType.dateTime, final String v) =>
          DateTime.parse(v).toUtc().toIso8601String(),
        (DriftSqlType.bool, final int v) => v == 1,
        (_, final v) => v,
      },
  };

  /// Cloud row -> local row, written through drift's own type mapping so
  /// dates end up in the same format as the ones written on this phone.
  Future<void> _upsertLocal(String table, Map<String, Object?> row) async {
    final columns = _syncedColumns(table).toList();
    final names = columns.map((c) => c.name).toList();
    final sql =
        'INSERT INTO $table (${names.join(', ')}) '
        'VALUES (${List.filled(names.length, '?').join(', ')}) '
        'ON CONFLICT(id) DO UPDATE SET '
        '${names.where((n) => n != 'id').map((n) => '$n = excluded.$n').join(', ')}';
    await _db.customInsert(
      sql,
      variables: [for (final c in columns) _toLocal(c.type, row[c.name])],
      updates: {_table(table)},
    );
  }

  static Variable _toLocal(Object type, Object? v) => switch (type) {
    DriftSqlType.dateTime => Variable<DateTime>(
      v == null ? null : DateTime.parse(v as String).toLocal(),
    ),
    DriftSqlType.bool => Variable<bool>(v as bool?),
    DriftSqlType.int => Variable<int>((v as num?)?.toInt()),
    _ => Variable<String>(v as String?),
  };
}
