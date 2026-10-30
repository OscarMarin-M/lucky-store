import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_store/core/quantity/presentation.dart';
import 'package:lucky_store/data/database/app_database.dart';
import 'package:lucky_store/data/repositories/drift_purchase_repository.dart';
import 'package:lucky_store/data/repositories/drift_sale_repository.dart';

import '../generated_migrations/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('every old version migrates to exactly the current schema', () async {
    for (final from in [1, 2, 3, 4]) {
      final connection = await verifier.startAt(from);
      final db = AppDatabase(connection);
      await verifier.migrateAndValidate(db, 5);
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
    await verifier.migrateAndValidate(db, 5);

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

  test('v4 "extra costs" become charges: added to total and profit', () async {
    final schema = await verifier.schemaAt(4);
    const ts = "'2026-10-29T10:00:00.000'";
    // v4 stored a sale of Bs 30 (profit 10) with Bs 5 of extras already
    // subtracted from its profit: profit 5.
    schema.rawDatabase
      ..execute(
        "INSERT INTO products (id, created_at, updated_at, name) "
        "VALUES ('p1', $ts, $ts, 'Snickers')",
      )
      ..execute(
        "INSERT INTO sales (id, created_at, updated_at, date, total_cents, "
        "profit_cents) VALUES ('s1', $ts, $ts, $ts, 3000, 500), "
        "('s2', $ts, $ts, $ts, 600, 200)",
      )
      ..execute(
        "INSERT INTO sale_extra_costs (id, created_at, updated_at, sale_id, "
        "concept, amount_cents) VALUES "
        "('e1', $ts, $ts, 's1', 'Mano de obra', 300), "
        "('e2', $ts, $ts, 's1', 'Empaque', 200)",
      );

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 5);

    final repo = DriftSaleRepository(db);
    final s1 = (await repo.getById('s1'))!;
    expect(s1.extraCharges.map((c) => c.concept), ['Mano de obra', 'Empaque']);
    expect(s1.total.cents, 3500); // 30 + 5 charged
    expect(s1.profit.cents, 1500); // 10 from products + 5 charged
    final s2 = (await repo.getById('s2'))!;
    expect(s2.total.cents, 600, reason: 'sales without extras untouched');
    expect(s2.profit.cents, 200);
    await db.close();
  });
}
