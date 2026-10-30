# Tienda App

App móvil (Flutter) para administrar una tienda física. Objetivo principal:
saber cuánto se gana o pierde por cada producto comprado/vendido.
La tienda de compra venta de dulces(americanos) por lo que se toma en cuenta productos unitarios o en cajas. Las ventas o conjuntos de productos vendidos tambien pueden ser hechas en cajas (promocionales) y se le pueden agregar costos adicionales(ej. mano de obra, impresion paquete, etc)

## Stack
- Flutter + Dart, Android primero
- SQLite con Drift (migraciones versionadas)
- Patrón repositorio: la UI nunca accede directo a la base de datos
- Comentario de funcionalidad en codigo NO generico.
- Pensado para añadir sincronización (Supabase) más adelante, NO implementarla aún

## Reglas de dominio (no romper)
- Moneda: Bolivianos (Bs). Todo el dinero se guarda como entero con decimales, 2 decimales a lo más (Ej: 1352.99)
- El inventario se guarda siempre en unidades base. Cada producto define
  `unidades_por_caja`. Compras y ventas registran cantidad + presentación
  (caja/unidad) y se convierten a unidades base.
- Costo: promedio ponderado. Ganancia por venta = (precio venta - costo promedio vigente) * cantidad.
  Diseñar para poder migrar a FIFO después.
- Todas las tablas: id UUID, created_at, updated_at, deleted_at (borrado lógico).
- Compras = "lotes" (`PurchaseLot`), cada modo con su propia lógica:
  - Caja: precio total de la caja, unidades por caja del lote (varía por proveedor),
    1 fecha de vencimiento opcional y 1 código.
  - Por unidades: precio por unidad, cantidad O monto pagado, rango de vencimiento opcional.
  - `unidades_por_caja` del producto es solo el valor por defecto; una compra nunca lo cambia.
- Venta = "pedido" (caja promocional = pedido con varios productos). Los cargos
  adicionales (mano de obra, empaque, impresión...) los PAGA EL CLIENTE: suman al
  total y a la ganancia del pedido, no descuentan stock ni son un costo de la tienda.
- Regalo = venta a Bs 0 (su costo queda como pérdida en la ganancia).
- Ganancia del período = ganancia de ventas - pérdida por bajas (vencido, dañado...).

## Flujo de trabajo
- Planificar antes de codificar en cambios grandes.
- Commits pequeños y descriptivos, una funcionalidad por rama.
- Tests obligatorios para la lógica de costos y conversión de cajas.
- Comandos: `flutter pub get`, `dart run build_runner build`, `flutter test`, `flutter analyze`
- Push: `git -c credential.helper=manager push origin main` (en esta PC `git push`
  a secas falla: no hay credential helper global ni `gh`).

## Notas técnicas
- Capas: `lib/core` (Money en centavos, UnitCost a 4 decimales, presentaciones),
  `lib/domain` (entidades, interfaces, casos de uso, CostStrategy),
  `lib/data` (Drift + repositorios), `lib/app/providers.dart` (Riverpod, raíz de
  composición), `lib/presentation` (pantallas). CRUD nuevo: heredar `DriftCrudRepository`.
- Cambio de esquema: subir `schemaVersion`, agregar el paso en `migration` y ejecutar
  `dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/`,
  luego `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/`
  y subir la versión esperada en `test/data/migration_test.dart`.
- Tests de widgets con Drift: sembrar datos ANTES de montar la pantalla (dentro de
  `tester.runAsync`); al final desmontar, `container.dispose()` y cerrar la base con
  `tester.runAsync(db.close)`. No usar `pumpAndSettle` con un campo de texto enfocado.
  Ver `test/presentation/*_page_test.dart`.
- Probar en el teléfono: `flutter build apk --debug` y luego
  `adb install -r build\app\outputs\flutter-apk\app-debug.apk`.