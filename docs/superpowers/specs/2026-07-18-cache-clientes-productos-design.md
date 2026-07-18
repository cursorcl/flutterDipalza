# Caché local (TTL persistido) para las listas de Clientes y Productos

**Fecha:** 2026-07-18
**Motivación:** la pantalla Clientes dispara una consulta al backend cada vez que se abre (`ClientesPage.initState`), y `ProductosPage` hace lo mismo con el catálogo completo en cada apertura (`obtainProducts()` en su propio `initState`, encima del caché en memoria del singleton `ProductsBloc`). Esta es la segunda mitad de la optimización — la primera mitad (caché en el servidor de `ClienteService`) ya está implementada en `dipalza.springboot` (ver `docs/superpowers/specs/2026-07-18-cache-clientes-design.md` de ese repo). Acá se ataca el lado cliente: evitar la llamada de red repetida cuando los datos no cambiaron, y que la lista se muestre de inmediato al abrir la app usando lo último guardado localmente.

## Alcance

- Lista completa de clientes (`ClientesProvider.obtenerListaClientes`, consumida hoy por `ClientesPage`).
- Lista completa de productos (`ProductosProvider.obtenerListaProductos`, consumida hoy por `ProductsBloc.obtainProducts()` / `ProductosPage`).
- **Explícitamente fuera de alcance:** cualquier otra consulta de productos que devuelva datos en vivo — `ProductosProvider.obtenerProducto(codigo)` (stock actual) y `obtenerPesoPromedioProducto(codigo)` (peso promedio de numerados). Estas nunca deben pasar por caché: se usan para validar stock antes de agregar un ítem a una venta y justo antes de guardarla.

## Hallazgos previos que definen el diseño

1. **Las rutas no filtran clientes hoy.** `prefs.ruta` (singular) nunca se escribe en el código; `obtenerListaClientesv2()` (que sí usa una ruta) no se llama desde ninguna pantalla. El fetch activo (`obtenerListaClientes`) solo envía `codigoVendedor` al backend, y el backend (`ClienteController.getClienteByVendedor`) filtra únicamente por esa columna, ignorando `codigoRuta`. Conclusión: la única dimensión de invalidación real para clientes es el vendedor — no hace falta considerar rutas.
2. **El catálogo de productos es global.** `ProductoController.getAllProductos()` no filtra por vendedor ni por ningún dato de usuario — es el mismo catálogo para todos. La key de su caché no necesita estar scopeada por vendedor.
3. **`prefs.vendedor` se escribe en un solo lugar:** `lib/src/page/login/login.page.dart:337` (`prefs.vendedor = response.codigo`), en cada login. El logout (`borrarCredenciales()`) no toca `vendedor` — persiste entre sesiones hasta el próximo login.
4. **Los providers hoy tragan los errores de red.** Tanto `ClientesProvider.obtenerListaClientes` (`lib/src/provider/cliente_provider.dart:18-25`) como `ProductosProvider.obtenerListaProductos` (`lib/src/provider/productos_provider.dart:15-23`) capturan cualquier excepción y devuelven `[]` en vez de propagarla. Con ese contrato, el bloc no puede distinguir "la red falló, hay que mantener el caché anterior" de "la lista legítimamente está vacía" (p. ej. un vendedor sin clientes) — ambos casos se ven igual: una lista vacía sin excepción. Como el manejo de errores de este diseño depende de poder distinguir ambos casos (ver más abajo), ambos métodos dejan de capturar-y-devolver-`[]` y en cambio propagan la excepción (`rethrow` o directamente sin `try/catch`). El único call site de cada uno hoy es justamente el que este mismo plan reescribe (`ClientesPage`/`ClientesBloc` y `ProductsBloc` respectivamente), así que no hay otros consumidores que dependan del contrato actual de "nunca lanza, devuelve `[]` en error".
5. **Bug latente en `ClientesModel.toJson()`** (`lib/src/model/clientes_model.dart:41-49`): escribe las keys capitalizadas (`"Rut"`, `"Codigo"`, `"Razon"`, `"Ruta"`...) mientras `fromJson()` las lee en minúscula (`json["rut"]`, `json["codigo"]`, ..., `json["codigoRuta"]` para `ruta`). Hoy nadie lo nota porque `clientesModelToJson` no se usa en ningún punto de la app (grep confirma cero llamadas). Como el caché depende de un round-trip correcto (`toJson` → `SharedPreferences` → `fromJson`), este bug se corrige como parte de este trabajo: alinear las keys de `toJson()` a minúscula, igual que `fromJson()` ya las espera. `ProductosModel` y `NumeradoModel` no tienen este problema (sus keys ya coinciden en ambas direcciones).

## Arquitectura

Un helper compartido, `CachedListStore<M>`, que persiste una lista serializada + timestamp en `SharedPreferences` bajo una key dada, y sabe si está vencida según un TTL. Dos blocs singleton lo usan — `ClientesBloc` (nuevo) y `ProductsBloc` (retrofit, solo en la carga de su lista completa). Patrón de cada bloc al iniciar: mostrar el caché local de inmediato si existe (sin esperar red); si está vencido según el TTL, disparar en segundo plano un refetch que reemplaza el valor del stream sin resetear a estado de carga (refresco silencioso, sin diffs visuales).

## Componentes

### `lib/src/share/cached_list_store.dart` (nuevo)

```dart
class CachedListEntry<M> {
  final List<M> items;
  final DateTime savedAt;
  CachedListEntry({required this.items, required this.savedAt});
  bool isStale(Duration ttl) => DateTime.now().difference(savedAt) > ttl;
}

class CachedListStore<M> {
  final String key;
  final String Function(List<M>) toJsonString;
  final List<M> Function(String) fromJsonString;

  CachedListStore({
    required this.key,
    required this.toJsonString,
    required this.fromJsonString,
  });

  Future<CachedListEntry<M>?> read() async { /* lee '${key}_data' + '${key}_savedAt' de SharedPreferences */ }
  Future<void> write(List<M> items) async { /* escribe ambas keys, savedAt = DateTime.now().toIso8601String() */ }
  Future<void> clear() async { /* remove de ambas keys */ }
}
```

`read()` devuelve `null` si falta cualquiera de las dos keys, si `savedAt` no parsea, o si `fromJsonString` lanza una excepción al deserializar (caché corrupto se trata como ausente, nunca como error fatal).

### `lib/src/bloc/clientes_bloc.dart` (nuevo)

- Singleton (mismo patrón que `ProductsBloc`/`RutasBloc`: `static final _singleton`, constructor privado).
- `CachedListStore<ClientesModel>` con `key: 'cache_clientes_${PreferenciasUsuario().vendedor}'`, `toJsonString: clientesModelToJson`, `fromJsonString: clientesModelFromJson`. La key se recalcula en cada acceso (no se cachea en un campo), así que si `prefs.vendedor` cambia entre una llamada y otra, automáticamente apunta a otra entrada — sin lógica de invalidación explícita.
- TTL: `Duration(minutes: 30)`.
- API pública:
  - `Stream<List<ClientesModel>> get clientesStream`
  - `List<ClientesModel> get clientesList` (último valor conocido, síncrono)
  - `Future<void> ensureFresh()` — llamada en `initState`, **sin awaitear** (fire-and-forget, mismo patrón que `ProductosPage` usa hoy con `obtainProducts()`; el `StreamBuilder` reacciona solo). Si hay caché, lo emite de inmediato; si está vencido (o no había caché), dispara `_refrescarDesdeRed()` en segundo plano. El `Future` que devuelve completa recién cuando termina todo (lectura de caché + refresh de red si correspondía) — existe para que quien sí quiera esperarlo pueda (p. ej. un test), pero ninguna página lo await.
  - `Future<void> forceRefresh()` — llamada desde el `RefreshIndicator` (que sí espera el `Future`, ya que `RefreshIndicator.onRefresh` requiere un `Future` para saber cuándo ocultar el spinner de refresco). Siempre dispara `_refrescarDesdeRed()`, sin mirar el TTL.
  - `_refrescarDesdeRed()`: llama `ClientesProvider.clientesProvider.obtenerListaClientes(prefs.vendedor, prefs.ruta)`, emite el resultado al stream y lo persiste vía `CachedListStore.write`. Si falla y el stream ya tenía un valor (de caché o de una carga previa), el error se ignora silenciosamente y se mantiene lo último conocido. Si falla y nunca hubo datos, el error se propaga (`_clientesController.addError`).

### `lib/src/bloc/productos_bloc.dart` (modificado)

- Se agrega un `CachedListStore<ProductosModel>` con `key: 'cache_productos_list'` (fija, global), `toJsonString: productosModelToJson`, `fromJsonString: productosModelFromJson`, TTL `Duration(minutes: 15)`.
- `obtainProducts()` se reemplaza por dos métodos con la misma forma que en `ClientesBloc`: `ensureFresh()` (TTL-aware) y `forceRefresh()` (bypassa TTL). La lógica interna de red/emit es la misma que ya existe en `obtainProducts()` hoy, solo se le agrega la lectura/escritura del `CachedListStore` y el chequeo de TTL antes de decidir si golpea la red.
- `searchProducts`, `searchProduct`, `updatePorduct` no cambian — siguen operando en memoria sobre `_productsController.valueOrNull`.
- El constructor privado (`ProductsBloc._internal()`) pasa a llamar `ensureFresh()` en vez de `obtainProducts()` directamente, para que la primera carga de la app también respete el caché persistido si ya existe.

### `lib/src/provider/cliente_provider.dart` (modificado)

- `obtenerListaClientes` pierde el parámetro `BuildContext context` (no se usa dentro del método — es dead code, y le impide a un bloc singleton invocarlo sin depender de un widget montado).
- `obtenerListaClientes` deja de capturar la excepción y devolver `[]`; ahora la propaga (ver hallazgo 4).

### `lib/src/provider/productos_provider.dart` (modificado)

- `obtenerListaProductos` deja de capturar la excepción y devolver `[]`; ahora la propaga (ver hallazgo 4). `obtenerProducto` y `obtenerPesoPromedioProducto` no cambian — quedan fuera de alcance.

### `lib/src/model/clientes_model.dart` (modificado)

- `ClientesModel.toJson()` pasa a usar las mismas keys en minúscula que `fromJson()` espera: `"rut"`, `"codigo"`, `"razon"`, `"direccion"`, `"telefono"`, `"ciudad"`, `"giro"`, `"codigoRuta"` (en vez de `"Rut"`, `"Codigo"`, `"Razon"`, `"Direccion"`, `"Telefono"`, `"Ciudad"`, `"Giro"`, `"Ruta"`).

### `lib/src/page/cliente/clientes.page.dart` (modificado)

- `initState` llama `ClientesBloc().ensureFresh()` en vez de `getListaClientes()`.
- El body pasa de la lista imperativa `_listaClientes` (poblada vía `setState` tras un `await`) a un `StreamBuilder<List<ClientesModel>>` sobre `ClientesBloc().clientesStream`, replicando los mismos 4 estados que ya maneja `ProductosPage` (`waiting` sin data → spinner, `hasError` → texto de error, sin data o vacía → `_createEmptyCard()`, con data → `_creaListaClientes`). La búsqueda local (`onSearchTextChanged`, filtro por `razon`) sigue operando igual, ahora sobre `ClientesBloc().clientesList` en vez de `_listaClientes`.
- El `RefreshIndicator` pasa a llamar `ClientesBloc().forceRefresh()` en vez de `getListaClientesRefrescar()`.

### `lib/src/page/producto/productos.page.dart` (modificado)

- `initState`: `_productsBloc.obtainProducts()` → `_productsBloc.ensureFresh()`.
- Pull-to-refresh (`getListaProductosRefrescar`): `obtainProducts()` → `_productsBloc.forceRefresh()`.

## Invalidación

- **Clientes:** la key de `CachedListStore` incluye el vendedor (`cache_clientes_<vendedor>`). Un cambio de vendedor en el login apunta a una key distinta → cache-miss natural para el nuevo vendedor. La entrada del vendedor anterior queda huérfana en `SharedPreferences` (JSON de una lista de clientes, tamaño acotado) — no se limpia activamente; es un costo de almacenamiento despreciable frente a la simplicidad de no necesitar lógica de invalidación explícita ni enganchar el login.
- **Productos:** key fija global, sin invalidación por vendedor (no aplica — mismo catálogo para todos). Solo expira por TTL.

## Manejo de errores

Ver `_refrescarDesdeRed()` arriba: con datos previos (de caché o de una carga anterior en el stream), un fallo de red se ignora silenciosamente y se sigue mostrando lo último conocido. Sin datos previos, el error se propaga al stream y ambas páginas ya tienen un estado de error en su `StreamBuilder`.

## Testing

- `test/unit/cached_list_store_test.dart` (nuevo): round-trip write→read; `isStale()` antes/después del TTL; `read()` devuelve `null` si falta alguna key, si el JSON está corrupto, o si no hay nada guardado. Usa `SharedPreferences.setMockInitialValues({})`.
- `test/unit/clientes_model_test.dart` (existente, se extiende): test de round-trip `toJson()` → `fromJson()` que hoy fallaría con el bug de capitalización, y pasa una vez corregido.
- Tests de `ClientesBloc`/`ProductsBloc` (nuevos, con `ClientesProvider`/`ProductosProvider` mockeados vía `mocktail`, ya presente en `dev_dependencies`): sin caché previo → dispara red; con caché fresco (`savedAt` reciente) → no dispara red, el stream emite directo el valor cacheado; con caché vencido → emite el valor cacheado primero y luego el de red al completar `_refrescarDesdeRed()`.

## Fuera de alcance

- Cualquier cambio a `obtenerProducto`/`obtenerPesoPromedioProducto` (consultas en vivo).
- Filtrado de clientes por ruta (evaluado y descartado: hoy no existe esa lógica en ningún punto de la app ni del backend consumido).
- Cambios al caché del backend (`ClienteService`), ya implementado por separado.
- Cambios de arquitectura de navegación (`HomePage` no usa `IndexedStack` para sus tabs, lo que también dispara un nuevo `initState` en cada visita al tab de Clientes/Productos) — el caché aquí diseñado hace que ese `initState` repetido sea barato (`ensureFresh()` con TTL vigente no golpea red), así que no es necesario tocar la navegación para resolver el problema original.
