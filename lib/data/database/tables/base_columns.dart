import 'package:drift/drift.dart';

/// Columns every table must have (see CLAUDE.md): UUID id, audit timestamps
/// and logical delete. Add `with BaseColumns` to a new table and it is done.
mixin BaseColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
