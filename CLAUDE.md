# Tienda App

App móvil (Flutter) para administrar una tienda física. Objetivo principal:
saber cuánto se gana o pierde por cada producto comprado/vendido.
La tienda de compra venta de dulces(americanos) por lo que se toma en cuenta productos unitarios o en cajas. Las ventas o conjuntos de productos vendidos tambien pueden ser hechas en cajas (promocionales) y se le pueden agregar costos adicionales(ej. mano de obra, impresion paquete, etc)

## Stack
- Flutter + Dart, Android primero
- SQLite con Drift (migraciones versionadas)
- Patrón repositorio: la UI nunca accede directo a la base de datos
- Comentario de funcionalidad en codigo NO generico.
- Varios usuarios (4-6, todos con acceso total por ahora) con Supabase, offline-first:
  cada teléfono trabaja sobre su SQLite y sincroniza cuando hay internet (también se
  usa fuera de la tienda, p. ej. al comprar). Roles/permisos: más adelante.

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
- Venta = "pedido" (caja promocional = pedido con varios productos). Cada cargo
  adicional (mano de obra, empaque, impresión...) dice quién lo paga
  (`paid_by_customer`, v7): si lo paga el CLIENTE suma al total y a la ganancia; si lo
  paga la TIENDA no cambia el total y se resta de la ganancia del pedido. Nunca
  descuentan stock.
- Regalo = venta a Bs 0 (su costo queda como pérdida en la ganancia).
- Ganancia del período = ganancia de ventas - pérdida por bajas (vencido, dañado...).
- Stock y costo promedio de un producto son DERIVADOS: se recalculan reproduciendo
  compras, ventas y bajas de todos los teléfonos en orden de fecha (`InventoryRebuilder`).
  El costo congelado en cada venta/baja nunca se modifica. Dos ventas offline de la
  última unidad dejan stock negativo (se muestra, no se bloquea al sincronizar).
- Documentos (compras, ventas, bajas) no se borran físicamente nunca: solo `deleted_at`.

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
- Probar en el teléfono: `flutter build apk --debug --dart-define-from-file=env/dev.json`
  y luego `adb install -r build\app\outputs\flutter-apk\app-debug.apk` (adb no está en el
  PATH: `$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe`). Sin el dart-define la app
  queda solo local (sin login ni sync). Si Gradle falla con PKIX, desactivar el escaneo
  HTTPS de AVG.
- APK para compartir con el equipo: `flutter build apk --release --dart-define-from-file=env/dev.json`
  (~60 MB; se firma con la clave debug de esta PC, así las versiones nuevas se instalan
  encima sin perder datos ni sesión).
- Sync con Supabase en `lib/data/sync/` (`SyncService`, `InventoryRebuilder`,
  `RemoteStore`) y `lib/app/sync_providers.dart` (sesión, `SyncController`):
  - Triggers de `lib/data/database/sync.drift` anotan cada cambio local en `sync_outbox`;
    push sube la cola en orden de FK, pull baja por `server_updated_at` (hora del
    servidor) y no reencola lo descargado. Un cambio local pendiente gana al descargado.
  - Products solo se encola por columnas de catálogo; stock/costo nunca suben.
  - Tabla nueva sincronizada: SQL en `supabase/migrations/` (se ejecuta a mano en el SQL
    Editor de Supabase), nombre en `synced_tables.dart` y triggers en `sync.drift`.
    Columna nueva en una tabla sincronizada: también su SQL, que debe ejecutarse ANTES
    de instalar el APK nuevo (si no, el push/pull falla por columna desconocida).
  - Compras, ventas y bajas guardan `registered_by` (correo de la sesión al
    registrar, v8) vía `currentUserProvider`; el Historial lo muestra.
  - Sincroniza al abrir, 3 s tras cada cambio, cada minuto (solo con la app en pantalla),
    deslizando hacia abajo en cualquier lista y con el icono de nube de cada pestaña.
  - Proyecto dev: `ttcyvyltxoddoxfcozzp`. `env/dev.json` (URL + publishable key) no se
    sube a git; formato en `env/example.json`. Usuarios: se crean en Supabase
    (Authentication → Users, "Auto Confirm"); la app no tiene registro propio.
  - Tests: `test/data/sync_service_test.dart` simula dos teléfonos con una nube falsa.