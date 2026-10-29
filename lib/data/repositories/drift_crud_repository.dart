import 'package:drift/drift.dart';

import '../../core/errors/domain_exception.dart';
import '../../core/util/clock.dart';
import '../../domain/entities/base_entity.dart';
import '../../domain/repositories/crud_repository.dart';
import '../database/app_database.dart';
import '../database/tables/base_columns.dart';

/// Generic CRUD over any table that uses [BaseColumns]. A new entity only
/// declares how to map rows (`fromRow`, `toInsertable`, `touch`); create,
/// update, soft delete, restore, get and watch come for free.
///
/// [T] is the Drift table, [D] its row class and [E] the domain entity.
abstract class DriftCrudRepository<T extends BaseColumns, D, E extends BaseEntity>
    implements CrudRepository<E> {
  DriftCrudRepository(this.db, this.table, {Clock clock = DateTime.now})
      : _clock = clock;

  final AppDatabase db;
  final TableInfo<T, D> table;
  final Clock _clock;

  E fromRow(D row);

  /// Full row for [entity] (all columns, including id and timestamps).
  Insertable<D> toInsertable(E entity);

  /// Copy of [entity] with `updatedAt` set to [now].
  E touch(E entity, DateTime now);

  /// Default ordering for `getAll`/`watchAll`.
  List<OrderingTerm Function(T)> get defaultOrder => const [];

  SimpleSelectStatement<T, D> selectRows({bool includeDeleted = false}) {
    final select = db.select(table);
    if (!includeDeleted) select.where((t) => t.deletedAt.isNull());
    if (defaultOrder.isNotEmpty) select.orderBy(defaultOrder);
    return select;
  }

  @override
  Future<E> create(E entity) async {
    await db.into(table).insert(toInsertable(entity));
    return entity;
  }

  @override
  Future<E> update(E entity) async {
    final touched = touch(entity, _clock());
    final updated = await (db.update(table)
          ..where((t) => t.id.equals(entity.id)))
        .write(toInsertable(touched));
    if (updated == 0) throw EntityNotFoundException('$E', entity.id);
    return touched;
  }

  @override
  Future<E?> getById(String id, {bool includeDeleted = false}) async {
    final select = db.select(table)..where((t) => t.id.equals(id));
    if (!includeDeleted) select.where((t) => t.deletedAt.isNull());
    final row = await select.getSingleOrNull();
    return row == null ? null : fromRow(row);
  }

  @override
  Future<List<E>> getAll({bool includeDeleted = false}) async {
    final rows = await selectRows(includeDeleted: includeDeleted).get();
    return rows.map(fromRow).toList();
  }

  @override
  Stream<List<E>> watchAll() =>
      selectRows().watch().map((rows) => rows.map(fromRow).toList());

  @override
  Future<void> softDelete(String id) => _setDeleted(id, _clock());

  @override
  Future<void> restore(String id) => _setDeleted(id, null);

  Future<void> _setDeleted(String id, DateTime? at) async {
    final updated = await (db.update(table)..where((t) => t.id.equals(id)))
        .write(RawValuesInsertable<D>({
      'deleted_at': Variable<DateTime>(at),
      'updated_at': Variable<DateTime>(_clock()),
    }));
    if (updated == 0) throw EntityNotFoundException('$E', id);
  }
}
