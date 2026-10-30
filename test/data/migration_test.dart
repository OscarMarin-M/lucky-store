import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/data/repositories/drift_purchase_repository.dart';

import '../generated_migrations/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('every old version migrates to exactly the current schema', () async {
    for (final from in [1, 2, 3]) {
      final connection = await verifier.startAt(from);
      final db = AppDatabase(connection);
      await verifier.migrateAndValidate(db, 4);
      await db.close();
    }
  });

  test('v1 purchases survive and box lines recover their box size', () async {
    final schema = await verifier.schemaAt(1);
    // Rows written by the v1 app: a box of 24 bought twice, and loose units.
    const ts = "'2026-01-01T00:00:00.000'"; // dates are stored as ISO text
    schema.rawDatabase
      ..execute(
        "INSERT INTO products (id, created_at, updated_at, name, units_per_box, "
        "suggested_price_unit_cents, stock_units, avg_cost_raw) "
        "VALUES ('p1', $ts, $ts, 'Snickers', 24, 300, 54, 20000)",
      )
      ..execute(
        "INSERT INTO purchases (id, created_at, updated_at, date, total_cents) "
        "VALUES ('c1', $ts, $ts, $ts, 10800)",
      )
      ..execute(
        "INSERT INTO purchase_lines (id, created_at, updated_at, purchase_id, "
        "product_id, quantity, presentation, units_base, line_total_cents, "
        "unit_cost_raw) VALUES "
        "('l1', $ts, $ts, 'c1', 'p1', 2, 'box', 48, 9600, 20000), "
        "('l2', $ts, $ts, 'c1', 'p1', 6, 'unit', 6, 1200, 20000)",
      );

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);

    final purchase =
        (await DriftPurchaseRepository(db).getById('c1'))!;
    final box = purchase.lines.firstWhere((l) => l.id == 'l1');
    final loose = purchase.lines.firstWhere((l) => l.id == 'l2');
    expect(box.presentation, Presentation.box);
    expect(box.unitsPerBox, 24);
    expect(box.unitsBase, 48);
    expect(box.expiryFrom, isNull);
    expect(loose.unitsPerBox, isNull);
    expect(loose.lineTotal.cents, 1200);
    await db.close();
  });
}
