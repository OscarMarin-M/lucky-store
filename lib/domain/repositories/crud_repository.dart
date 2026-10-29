import '../entities/base_entity.dart';

/// Basic operations every entity gets. Reads hide soft-deleted rows unless
/// asked otherwise.
abstract interface class CrudRepository<E extends BaseEntity> {
  Future<E> create(E entity);

  /// Throws `EntityNotFoundException` when [entity] does not exist.
  Future<E> update(E entity);

  Future<E?> getById(String id, {bool includeDeleted = false});

  Future<List<E>> getAll({bool includeDeleted = false});

  Stream<List<E>> watchAll();

  /// Logical delete (sets `deleted_at`).
  Future<void> softDelete(String id);

  Future<void> restore(String id);
}
