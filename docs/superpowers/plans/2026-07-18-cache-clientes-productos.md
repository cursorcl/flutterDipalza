# Caché local (TTL persistido) para Clientes y Productos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Evitar que las pantallas Clientes y Productos disparen una consulta de red cada vez que se abren, mostrando de inmediato lo último guardado en `SharedPreferences` y refrescando en segundo plano solo cuando el TTL venció (30 min clientes, 15 min productos), sin diffs visuales.

**Architecture:** Un helper compartido `CachedListStore<M>` persiste una lista serializada + timestamp en `SharedPreferences` y sabe si está vencida. Dos blocs singleton lo usan — `ClientesBloc` (nuevo) y `ProductsBloc` (retrofit, solo en su carga de lista completa). Cada bloc expone `ensureFresh()` (TTL-aware, para `initState`, fire-and-forget) y `forceRefresh()` (bypassa TTL, para pull-to-refresh, awaited por `RefreshIndicator`). Las páginas consumen el stream del bloc vía `StreamBuilder`, igual que ya hace `ProductosPage` hoy.

**Tech Stack:** Flutter/Dart, `shared_preferences` (persistencia), `rxdart` `BehaviorSubject` (mismo patrón que `ProductsBloc`/`RutasBloc` ya usan), `flutter_test` (tests unitarios).

## Global Constraints

- TTL clientes: `Duration(minutes: 30)`. TTL productos: `Duration(minutes: 15)`.
- Key de caché de clientes: `'cache_clientes_${PreferenciasUsuario().vendedor}'` (scopeada por vendedor — un cambio de vendedor apunta a otra key automáticamente, sin lógica de invalidación explícita).
- Key de caché de productos: `'cache_productos_list'` (fija, global — el catálogo es el mismo para todos los vendedores).
- Fuera de alcance: `ProductosProvider.obtenerProducto` y `obtenerPesoPromedioProducto` (consultas en vivo) — no se tocan, nunca pasan por caché.
- Fuera de alcance: filtrado de clientes por ruta, cambios de navegación (`IndexedStack`), caché del backend (ya implementado por separado).
- `ClientesProvider.obtenerListaClientes` y `ProductosProvider.obtenerListaProductos` dejan de capturar errores y devolver `[]`; deben propagar la excepción (con log previo, mismo estilo que ya usa cada archivo).
- Refresco silencioso: cuando ya había datos (de caché o de una carga previa) y el refetch de red falla, el error se ignora y se mantiene el último valor conocido — nunca se resetea a estado de error si ya se había mostrado algo.

Spec de referencia: `docs/superpowers/specs/2026-07-18-cache-clientes-productos-design.md`

---

## File Structure

- **Create:** `lib/src/share/cached_list_store.dart` — `CachedListStore<M>` + `CachedListEntry<M>`.
- **Test:** `test/unit/cached_list_store_test.dart` — cobertura completa del helper (única pieza con lógica no trivial de este plan).
- **Modify:** `lib/src/model/clientes_model.dart` — corrige las keys de `toJson()` para que hagan round-trip con `fromJson()`.
- **Modify (test):** `test/unit/clientes_model_test.dart` — agrega los tests de round-trip que exponen y verifican el fix.
- **Modify:** `lib/src/provider/cliente_provider.dart` — quita el parámetro `BuildContext context` de `obtenerListaClientes` y propaga errores en vez de devolver `[]`.
- **Modify:** `lib/src/provider/productos_provider.dart` — `obtenerListaProductos` propaga errores en vez de devolver `[]`.
- **Create:** `lib/src/bloc/clientes_bloc.dart` — `ClientesBloc` (singleton, `ensureFresh()`/`forceRefresh()`).
- **Modify:** `lib/src/page/cliente/clientes.page.dart` — pasa a `StreamBuilder` sobre `ClientesBloc().clientesStream`.
- **Modify:** `lib/src/bloc/productos_bloc.dart` — agrega `CachedListStore`, reemplaza `obtainProducts()` por `ensureFresh()`/`forceRefresh()`.
- **Modify:** `lib/src/page/producto/productos.page.dart` — usa `ensureFresh()`/`forceRefresh()` en vez de `obtainProducts()`.

`ClientesBloc`/`ProductsBloc` no llevan test unitario propio (ver spec, sección Testing): son singletons que llaman al provider estático correspondiente, igual que el resto de los blocs de este código (`RutasBloc` incluido), ninguno de los cuales tiene tests hoy. Su lógica de decisión (¿está vencido?) ya la cubre `CachedListStore`; el resto se verifica manualmente en la Task 6.

---

## Task 1: `CachedListStore` — helper de caché persistido con TTL

**Files:**
- Create: `lib/src/share/cached_list_store.dart`
- Test: `test/unit/cached_list_store_test.dart`

**Interfaces:**
- Produces: `CachedListStore<M>({required String key, required String Function(List<M>) toJsonString, required List<M> Function(String) fromJsonString})`, con métodos `Future<CachedListEntry<M>?> read()`, `Future<void> write(List<M> items)`, `Future<void> clear()`. `CachedListEntry<M>({required List<M> items, required DateTime savedAt})` con `bool isStale(Duration ttl)`. Usado por las Tasks 4 y 5 (`ClientesBloc`, `ProductsBloc`).

- [ ] **Step 1: Escribir los tests que fallan**

Crear `test/unit/cached_list_store_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dipalza_movil/src/share/cached_list_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  String toJsonString(List<String> items) => jsonEncode(items);
  List<String> fromJsonString(String raw) =>
      (jsonDecode(raw) as List).map((e) => e as String).toList();

  CachedListStore<String> buildStore() => CachedListStore<String>(
        key: 'test_key',
        toJsonString: toJsonString,
        fromJsonString: fromJsonString,
      );

  group('CachedListStore', () {
    test('read devuelve null si nunca se escribió nada', () async {
      final store = buildStore();

      expect(await store.read(), isNull);
    });

    test('write seguido de read hace round-trip de los items', () async {
      final store = buildStore();
      await store.write(['a', 'b', 'c']);

      final entry = await store.read();

      expect(entry, isNotNull);
      expect(entry!.items, ['a', 'b', 'c']);
    });

    test('read devuelve null si el JSON guardado está corrupto', () async {
      SharedPreferences.setMockInitialValues({
        'test_key_data': 'esto no es json valido',
        'test_key_savedAt': DateTime.now().toIso8601String(),
      });
      final store = buildStore();

      expect(await store.read(), isNull);
    });

    test('read devuelve null si falta la marca de tiempo', () async {
      SharedPreferences.setMockInitialValues({
        'test_key_data': jsonEncode(['a']),
      });
      final store = buildStore();

      expect(await store.read(), isNull);
    });

    test('clear borra los datos guardados', () async {
      final store = buildStore();
      await store.write(['a']);

      await store.clear();

      expect(await store.read(), isNull);
    });
  });

  group('CachedListEntry.isStale', () {
    test('false cuando savedAt está dentro del TTL', () {
      final entry = CachedListEntry<String>(
        items: ['a'],
        savedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      expect(entry.isStale(const Duration(minutes: 30)), isFalse);
    });

    test('true cuando savedAt superó el TTL', () {
      final entry = CachedListEntry<String>(
        items: ['a'],
        savedAt: DateTime.now().subtract(const Duration(minutes: 31)),
      );

      expect(entry.isStale(const Duration(minutes: 30)), isTrue);
    });
  });
}
```

- [ ] **Step 2: Ejecutar los tests y confirmar que fallan**

Run: `flutter test test/unit/cached_list_store_test.dart`
Expected: FAIL — no compila (`package:dipalza_movil/src/share/cached_list_store.dart` no existe).

- [ ] **Step 3: Implementar `CachedListStore`**

Crear `lib/src/share/cached_list_store.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

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

  String get _dataKey => '${key}_data';

  String get _savedAtKey => '${key}_savedAt';

  Future<CachedListEntry<M>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dataKey);
    final savedAtRaw = prefs.getString(_savedAtKey);
    if (raw == null || savedAtRaw == null) return null;

    final savedAt = DateTime.tryParse(savedAtRaw);
    if (savedAt == null) return null;

    try {
      final items = fromJsonString(raw);
      return CachedListEntry<M>(items: items, savedAt: savedAt);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(List<M> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, toJsonString(items));
    await prefs.setString(_savedAtKey, DateTime.now().toIso8601String());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dataKey);
    await prefs.remove(_savedAtKey);
  }
}
```

- [ ] **Step 4: Ejecutar los tests y confirmar que pasan**

Run: `flutter test test/unit/cached_list_store_test.dart`
Expected: PASS (7 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/share/cached_list_store.dart test/unit/cached_list_store_test.dart
git commit -m "feat: agrega CachedListStore para persistir listas con TTL"
```

---

## Task 2: Corrige el round-trip de `ClientesModel.toJson()`

**Files:**
- Modify: `lib/src/model/clientes_model.dart`
- Modify: `test/unit/clientes_model_test.dart`

**Interfaces:**
- Consumes: ninguna de este plan.
- Produces: `ClientesModel.toJson()` con keys en minúscula, consistentes con `fromJson()` — la Task 4 depende de que este round-trip funcione (`CachedListStore<ClientesModel>` usa `clientesModelToJson`/`clientesModelFromJson`, que a su vez llaman a `toJson()`/`fromJson()` por elemento).

- [ ] **Step 1: Agregar los tests que fallan**

En `test/unit/clientes_model_test.dart`, agregar estos dos tests dentro del `group('ClientesModel', () { ... })` existente, antes del `});` que lo cierra:

```dart
    test('toJson -> fromJson round trip conserva los datos', () {
      final original = ClientesModel(
          rut: '12345678-5',
          codigo: '001',
          razon: 'Empresa Test',
          direccion: 'Calle 123',
          telefono: '+56912345678',
          ciudad: 'Santiago',
          giro: 'Comercial',
          ruta: 'R01');

      final reconstruido = ClientesModel.fromJson(original.toJson());

      expect(reconstruido.rut, original.rut);
      expect(reconstruido.codigo, original.codigo);
      expect(reconstruido.razon, original.razon);
      expect(reconstruido.direccion, original.direccion);
      expect(reconstruido.telefono, original.telefono);
      expect(reconstruido.ciudad, original.ciudad);
      expect(reconstruido.giro, original.giro);
      expect(reconstruido.ruta, original.ruta);
    });

    test('clientesModelToJson -> clientesModelFromJson round trip conserva los datos', () {
      final originales = [
        ClientesModel(
            rut: '1',
            codigo: '01',
            razon: 'A',
            direccion: 'a',
            telefono: '1',
            ciudad: 'S',
            giro: 'C',
            ruta: 'R1'),
        ClientesModel(
            rut: '2',
            codigo: '02',
            razon: 'B',
            direccion: 'b',
            telefono: '2',
            ciudad: 'S',
            giro: 'C',
            ruta: 'R2'),
      ];

      final jsonString = clientesModelToJson(originales);
      final reconstruidos = clientesModelFromJson(jsonString);

      expect(reconstruidos.length, 2);
      expect(reconstruidos[0].razon, 'A');
      expect(reconstruidos[0].ruta, 'R1');
      expect(reconstruidos[1].razon, 'B');
      expect(reconstruidos[1].ruta, 'R2');
    });
```

- [ ] **Step 2: Ejecutar los tests y confirmar que fallan**

Run: `flutter test test/unit/clientes_model_test.dart`
Expected: FAIL en los 2 tests nuevos — `reconstruido.rut` es `''` en vez de `'12345678-5'` (y análogos), porque `toJson()` escribe `"Rut"` pero `fromJson()` busca `"rut"`.

- [ ] **Step 3: Corregir `ClientesModel.toJson()`**

En `lib/src/model/clientes_model.dart`, reemplazar:

```dart
  Map<String, dynamic> toJson() => {
        "Rut": rut,
        "Codigo": codigo,
        "Razon": razon,
        "Direccion": direccion,
        "Telefono": telefono,
        "Ciudad": ciudad,
        "Giro": giro,
        "Ruta": ruta
      };
```

por:

```dart
  Map<String, dynamic> toJson() => {
        "rut": rut,
        "codigo": codigo,
        "razon": razon,
        "direccion": direccion,
        "telefono": telefono,
        "ciudad": ciudad,
        "giro": giro,
        "codigoRuta": ruta
      };
```

- [ ] **Step 4: Ejecutar los tests y confirmar que pasan**

Run: `flutter test test/unit/clientes_model_test.dart`
Expected: PASS (7 tests: los 5 existentes + los 2 nuevos).

- [ ] **Step 5: Commit**

```bash
git add lib/src/model/clientes_model.dart test/unit/clientes_model_test.dart
git commit -m "fix: corrige round-trip de ClientesModel.toJson/fromJson"
```

---

## Task 3: Providers propagan errores en vez de devolver `[]`

**Files:**
- Modify: `lib/src/provider/cliente_provider.dart`
- Modify: `lib/src/provider/productos_provider.dart`

**Interfaces:**
- Produces: `ClientesProvider.obtenerListaClientes(String codVendedor, String codRuta)` (sin `BuildContext`, lanza en vez de devolver `[]` en error) y `ProductosProvider.obtenerListaProductos()` (lanza en vez de devolver `[]` en error). Las Tasks 4 y 5 dependen de estas firmas exactas.

Sin test dedicado: son cambios mecánicos de 2 líneas cada uno (quitar el `return []`/parámetro, agregar `rethrow`) sobre providers que hoy no tienen tests (ningún provider de este código los tiene — mockear `Dio`/`ApiClient` no tiene precedente en este proyecto). Se verifican junto con las Tasks 4 y 5 vía `flutter analyze` y la verificación manual de la Task 6.

- [ ] **Step 1: Quitar el parámetro `context` y propagar errores en `ClientesProvider`**

En `lib/src/provider/cliente_provider.dart`, reemplazar:

```dart
  Future<List<ClientesModel>> obtenerListaClientes(
      String codVendedor, String codRuta, BuildContext context) async {
    try {
      final response = await _dio.get('/api/clientes/vendedor', queryParameters: {'codigoVendedor': codVendedor});
      final List<dynamic> data = response.data;
      return data.map((json) => ClientesModel.fromJson(json)).toList();
    } catch (error) {
      print(error.toString());
      return [];
    }
  }
```

por:

```dart
  Future<List<ClientesModel>> obtenerListaClientes(
      String codVendedor, String codRuta) async {
    try {
      final response = await _dio.get('/api/clientes/vendedor', queryParameters: {'codigoVendedor': codVendedor});
      final List<dynamic> data = response.data;
      return data.map((json) => ClientesModel.fromJson(json)).toList();
    } catch (error) {
      print(error.toString());
      rethrow;
    }
  }
```

Y quitar el import ahora no usado en el mismo archivo (era solo para `BuildContext`):

```dart
import 'package:flutter/material.dart';
```

- [ ] **Step 2: Propagar errores en `ProductosProvider.obtenerListaProductos`**

En `lib/src/provider/productos_provider.dart`, reemplazar:

```dart
  Future<List<ProductosModel>> obtenerListaProductos() async {
    try {
      final response = await _dio.get('/api/productos');
      final List<dynamic> data = response.data;
      return data.map((json) => ProductosModel.fromJson(json)).toList();
    } catch (error) {
      return [];
    }
  }
```

por:

```dart
  Future<List<ProductosModel>> obtenerListaProductos() async {
    try {
      final response = await _dio.get('/api/productos');
      final List<dynamic> data = response.data;
      return data.map((json) => ProductosModel.fromJson(json)).toList();
    } catch (error) {
      log('Error al ejecutar obtenerListaProductos',
          name: 'ProductosProvider', error: error);
      rethrow;
    }
  }
```

(`log` de `dart:developer` ya está importado en este archivo — mismo estilo que `obtenerProducto`/`obtenerPesoPromedioProducto` más abajo.)

- [ ] **Step 3: Verificar que el proyecto sigue analizando limpio**

Run: `flutter analyze lib/src/provider/cliente_provider.dart lib/src/provider/productos_provider.dart`
Expected: `No issues found!` — en particular, ningún error de "unused import" ni de llamador roto (el único call site de cada método, en `clientes.page.dart`/`productos_bloc.dart`, se actualiza en las Tasks 4 y 5; hasta entonces esos dos archivos quedarán con un error de compilación esperado por el parámetro faltante — no correr `flutter analyze` sobre el proyecto completo todavía).

- [ ] **Step 4: Commit**

```bash
git add lib/src/provider/cliente_provider.dart lib/src/provider/productos_provider.dart
git commit -m "fix: providers de clientes y productos propagan errores en vez de devolver lista vacía"
```

---

## Task 4: `ClientesBloc` y refactor de `ClientesPage`

**Files:**
- Create: `lib/src/bloc/clientes_bloc.dart`
- Modify: `lib/src/page/cliente/clientes.page.dart`

**Interfaces:**
- Consumes: `CachedListStore<ClientesModel>` (Task 1), `clientesModelToJson`/`clientesModelFromJson` (Task 2, ya con round-trip correcto), `ClientesProvider.obtenerListaClientes(String, String)` (Task 3, ya sin `BuildContext` y ya propagando errores), `PreferenciasUsuario().vendedor`/`.ruta`.
- Produces: `ClientesBloc()` (singleton) con `Stream<List<ClientesModel>> clientesStream`, `List<ClientesModel> clientesList`, `Future<void> ensureFresh()`, `Future<void> forceRefresh()`.

- [ ] **Step 1: Implementar `ClientesBloc`**

Crear `lib/src/bloc/clientes_bloc.dart`:

```dart
import 'dart:async';

import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/provider/cliente_provider.dart';
import 'package:dipalza_movil/src/share/cached_list_store.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:rxdart/rxdart.dart';

class ClientesBloc {
  static final ClientesBloc _singleton = ClientesBloc._internal();

  factory ClientesBloc() => _singleton;

  ClientesBloc._internal();

  static const _ttl = Duration(minutes: 30);

  final _clientesController = BehaviorSubject<List<ClientesModel>>();

  Stream<List<ClientesModel>> get clientesStream => _clientesController.stream;

  List<ClientesModel> get clientesList => _clientesController.valueOrNull ?? [];

  CachedListStore<ClientesModel> get _store => CachedListStore<ClientesModel>(
        key: 'cache_clientes_${PreferenciasUsuario().vendedor}',
        toJsonString: clientesModelToJson,
        fromJsonString: clientesModelFromJson,
      );

  Future<void> ensureFresh() async {
    final cached = await _store.read();
    if (cached != null) {
      _clientesController.sink.add(cached.items);
      if (!cached.isStale(_ttl)) return;
    }
    await _refrescarDesdeRed();
  }

  Future<void> forceRefresh() => _refrescarDesdeRed();

  Future<void> _refrescarDesdeRed() async {
    final prefs = PreferenciasUsuario();
    try {
      final lista = await ClientesProvider.clientesProvider
          .obtenerListaClientes(prefs.vendedor, prefs.ruta);
      _clientesController.sink.add(lista);
      await _store.write(lista);
    } catch (error) {
      if (_clientesController.valueOrNull == null) {
        _clientesController.addError(error);
      }
    }
  }
}
```

- [ ] **Step 2: Refactorizar `ClientesPage` para consumir el bloc**

Reemplazar el contenido completo de `lib/src/page/cliente/clientes.page.dart` por:

```dart
import 'package:dipalza_movil/src/bloc/clientes_bloc.dart';
import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/app_routes.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:flutter/material.dart';

import '../../share/app.navigator.dart';
import '../../share/app_scaffold_key.dart';
import '../../widget/connectivity_banner.widget.dart';

class ClientesPage extends StatefulWidget {
  final bool isForSelection;

  const ClientesPage({Key? key, this.isForSelection = false}) : super(key: key);

  @override
  _ClientesPageState createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ClientesBloc _clientesBloc = ClientesBloc();
  TextEditingController controller = new TextEditingController();
  bool _verBuscar = false;

  @override
  void initState() {
    super.initState();
    _clientesBloc.ensureFresh();
  }

  Future<void> getListaClientesRefrescar() => _clientesBloc.forceRefresh();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            AppScaffoldKey.homeKey.currentState?.openDrawer();
          },
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: colorRojoBase(),
        title: Container(
          child: const Center(
            child: Text(
              'Clientes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () {
              setState(() {
                _verBuscar = true;
              });
            },
          ),
        ],
      ),
      body: Stack(children: <Widget>[
        const Positioned.fill(
          child: FondoWidget(),
        ),
        Positioned.fill(
          child: Column(
            children: <Widget>[
              const ConnectivityBanner(),
              _verBuscar ? _creaInputBuscar(context) : Container(),
              Expanded(
                child: StreamBuilder<List<ClientesModel>>(
                  stream: _clientesBloc.clientesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final listaCompleta = snapshot.data ?? [];
                    final listaAMostrar = _filtrarLista(listaCompleta);
                    return _creaListaClientes(context, listaAMostrar);
                  },
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  List<ClientesModel> _filtrarLista(List<ClientesModel> listaCompleta) {
    if (controller.text.isEmpty) return listaCompleta;
    return listaCompleta
        .where((cliente) => cliente.razon.contains(controller.text))
        .toList();
  }

  Widget _creaInputBuscar(BuildContext context) {
    return AnimatedOpacity(
      opacity: _verBuscar ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        color: colorRojoBase(),
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Card(
            child: new ListTile(
              leading: const Icon(Icons.search),
              title: new TextField(
                controller: controller,
                decoration: const InputDecoration(
                    hintText: 'Buscar', border: InputBorder.none),
                onChanged: onSearchTextChanged,
              ),
              trailing: new IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  controller.clear();
                  onSearchTextChanged('');
                  setState(() {
                    _verBuscar = false;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  onSearchTextChanged(String text) {
    setState(() {});
  }

  Widget _creaListaClientes(
      BuildContext context, List<ClientesModel> listaCliente) {
    if (listaCliente.length == 0) return _createEmptyCard();

    return RefreshIndicator(
      onRefresh: getListaClientesRefrescar,
      child: ListView.builder(
        itemCount: listaCliente.length,
        itemBuilder: (context, i) {
          return _creaCard(listaCliente[i]);
        },
      ),
    );
  }

  _createEmptyCard() {
    return Card(
        child: ListTile(
      leading: CircleAvatar(
        radius: 25,
        child: const Icon(Icons.account_box),
        backgroundColor: colorRojoBase(),
        foregroundColor: Colors.white,
      ),
      title: const Text('No existen Clientes para la conbinación Vendedor / Ruta.'),
    ));
  }

  _creaCard(ClientesModel cliente) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          child: const Icon(Icons.account_box),
          backgroundColor: colorRojoBase(),
          foregroundColor: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(cliente.razon,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                )),
            const SizedBox(
              height: 2.0,
            ),
            Text(getFormatRut(cliente.rut),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                )),
            const SizedBox(
              height: 5.0,
            )
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(cliente.direccion, style: const TextStyle(fontSize: 12.0)),
            Text(cliente.telefono, style: const TextStyle(fontSize: 12.0))
          ],
        ),
        trailing: IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            onPressed: () async {
              try {
                var ventaModel =
                await VentaProvider.ventaProvider.obtenerUltimaVenta(cliente);
                if (ventaModel == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Este cliente no tiene ventas asociadas.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return; // No navega
                } else {
                  AppNavigator.pushNamed(AppRoutes.listadoUltimaVenta,
                      arguments: {'ventaModel': ventaModel});
                }
              } catch(e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No se pudo completar la operación: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }),
        onTap: () {
          if (widget.isForSelection) {
            AppNavigator.pop(cliente);
          } else {
            // Tu acción original
          }
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Verificar que el proyecto analiza limpio y la suite de tests completa sigue pasando**

Run: `flutter analyze lib/src/bloc/clientes_bloc.dart lib/src/page/cliente/clientes.page.dart lib/src/provider/cliente_provider.dart`
Expected: `No issues found!`

Run: `flutter test`
Expected: todos los tests existentes + los de las Tasks 1 y 2 en PASS (ningún test ejercita `ClientesPage`/`ClientesBloc` directamente, así que esta corrida no agrega casos nuevos, pero confirma que nada se rompió en el resto de la suite).

- [ ] **Step 4: Commit**

```bash
git add lib/src/bloc/clientes_bloc.dart lib/src/page/cliente/clientes.page.dart
git commit -m "feat: agrega ClientesBloc con caché TTL y migra ClientesPage a StreamBuilder"
```

---

## Task 5: Retrofit de `ProductsBloc` y `ProductosPage`

**Files:**
- Modify: `lib/src/bloc/productos_bloc.dart`
- Modify: `lib/src/page/producto/productos.page.dart`

**Interfaces:**
- Consumes: `CachedListStore<ProductosModel>` (Task 1), `productosModelToJson`/`productosModelFromJson` (ya existentes, sin bug de round-trip), `ProductosProvider.obtenerListaProductos()` (Task 3, ya propagando errores).
- Produces: `ProductsBloc` mantiene `productsStream`, `productList`, `initialLoadDone`, `searchProducts`, `searchProduct`, `updatePorduct`, `dispose()` (sin cambios de firma — otros call sites como `venta.item.detalle.edicion.dart` no se tocan). `obtainProducts()` se elimina, reemplazado por `ensureFresh()`/`forceRefresh()`.

- [ ] **Step 1: Retrofit de `ProductsBloc`**

Reemplazar el contenido completo de `lib/src/bloc/productos_bloc.dart` por:

```dart
import 'dart:async';

import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/provider/productos_provider.dart';
import 'package:dipalza_movil/src/share/cached_list_store.dart';
import 'package:rxdart/rxdart.dart';

class ProductsBloc {
  static final ProductsBloc _singleton = new ProductsBloc._internal();
  final _productsController = BehaviorSubject<List<ProductosModel>>();

  static const _ttl = Duration(minutes: 15);

  final _store = CachedListStore<ProductosModel>(
    key: 'cache_productos_list',
    toJsonString: productosModelToJson,
    fromJsonString: productosModelFromJson,
  );

  // --- 1. AÑADIMOS UN FUTURE PARA CONTROLAR LA CARGA INICIAL ---
  late Future<void> _initialLoad;

  // --- 3. LO EXPONEMOS PARA QUE OTROS LO PUEDAN 'AWAIT' ---
  Future<void> get initialLoadDone => _initialLoad;

  factory ProductsBloc() {
    return _singleton;
  }

  ProductsBloc._internal() {
    _initialLoad = ensureFresh();
  }

  // Acá deben conectarse los interesados en escuchar los productos
  Stream<List<ProductosModel>> get productsStream => _productsController.stream;

  // Obtiene el valor que recuerda _productosController.
  List<ProductosModel> get productList => _productsController.value;

  /// TTL-aware: si hay caché lo emite de inmediato; si está vencido (o no
  /// había caché), refresca desde la red en segundo plano.
  Future<void> ensureFresh() async {
    final cached = await _store.read();
    if (cached != null) {
      _productsController.sink.add(cached.items);
      if (!cached.isStale(_ttl)) return;
    }
    await _refrescarDesdeRed();
  }

  /// Bypassa el TTL: siempre refresca desde la red. Usado por pull-to-refresh.
  Future<void> forceRefresh() => _refrescarDesdeRed();

  Future<void> _refrescarDesdeRed() async {
    try {
      final lista =
          await ProductosProvider.productosProvider.obtenerListaProductos();
      _productsController.sink.add(lista);
      await _store.write(lista);
    } catch (e) {
      if (_productsController.valueOrNull == null) {
        _productsController.addError(e);
      }
    }
  }

  /// Busca y devuelve una LISTA de productos que coincidan con el término.
  List<ProductosModel> searchProducts(String termino) {
    if (termino.isEmpty) return [];

    final listaCompleta = _productsController.valueOrNull;
    if (listaCompleta == null || listaCompleta.isEmpty) return [];

    final terminoUpper = termino.toUpperCase();

    // Lógica de filtro (similar a la de productos.page.dart)
    return listaCompleta.where((producto) {
      final descMatch =
          producto.descripcion.toUpperCase().contains(terminoUpper);
      final codeMatch = producto.articulo.toUpperCase().contains(terminoUpper);
      return descMatch || codeMatch;
    }).toList();
  }

  /// Busca un producto por término (código o nombre) en la lista cacheadA.
  /// Es síncrono, por lo que es muy rápido.
  ProductosModel? searchProduct(String termino) {
    if (termino.isEmpty) return null;

    // 1. Obtiene la lista actual que tiene el BLoC
    final listaCompleta = _productsController.valueOrNull;
    if (listaCompleta == null || listaCompleta.isEmpty) return null;

    final terminoUpper = termino.toUpperCase();
    ProductosModel? productoEncontrado;

    // 2. Intenta buscar por CÓDIGO/ARTÍCULO exacto primero (es lo más probable)
    //    Esta lógica es la misma de tu ProductosPage
    try {
      productoEncontrado = listaCompleta
          .firstWhere((p) => p.articulo.toUpperCase() == terminoUpper);
      return productoEncontrado;
    } catch (e) {
      // No se encontró por código, buscar por nombre...
    }

    // 3. Si no, busca por DESCRIPCIÓN (primera coincidencia)
    try {
      productoEncontrado = listaCompleta.firstWhere(
          (p) => p.descripcion.toUpperCase().contains(terminoUpper));
      return productoEncontrado;
    } catch (e) {
      // No se encontró tampoco
      return null;
    }
  }

  /// Actualiza un producto específico dentro de la lista cacheada del BLoC.
  void updatePorduct(ProductosModel productoActualizado) {
    // 1. Obtiene la lista actual que tiene el BLoC
    final actualList = _productsController.valueOrNull;

    if (actualList == null || actualList.isEmpty) return null;
    // 2. Busca el índice del producto que queremos actualizar
    //    (Asegúrate de que tu ProductosModel tenga un 'id' o 'articulo' único)
    final index = actualList
        .indexWhere((p) => p.articulo == productoActualizado.articulo);

    // 3. Si lo encuentra, lo reemplaza
    if (index != -1) {
      actualList[index] = productoActualizado;

      // 4. Mete la lista (ya modificada) de nuevo en el stream
      //    El StreamBuilder en ProductosPage se actualizará automáticamente.
      _productsController.sink.add(actualList);
    }
  }

  dispose() {
    _productsController.close();
  }
}
```

- [ ] **Step 2: Actualizar `ProductosPage` para usar `ensureFresh()`/`forceRefresh()`**

En `lib/src/page/producto/productos.page.dart`, reemplazar:

```dart
  @override
  void initState() {
    super.initState();
    _productsBloc.obtainProducts();
  }
```

por:

```dart
  @override
  void initState() {
    super.initState();
    _productsBloc.ensureFresh();
  }
```

Y reemplazar:

```dart
  Future<void> getListaProductosRefrescar() async {
    // Solo le decimos al BLoC que recargue. El StreamBuilder se encargará del resto.
    await _productsBloc.obtainProducts();
  }
```

por:

```dart
  Future<void> getListaProductosRefrescar() async {
    // Solo le decimos al BLoC que recargue. El StreamBuilder se encargará del resto.
    await _productsBloc.forceRefresh();
  }
```

- [ ] **Step 3: Verificar que el proyecto analiza limpio y la suite completa pasa**

Run: `flutter analyze lib/src/bloc/productos_bloc.dart lib/src/page/producto/productos.page.dart lib/src/provider/productos_provider.dart lib/src/page/ventas/venta.item.detalle.edicion.dart`
Expected: `No issues found!` (se incluye `venta.item.detalle.edicion.dart` porque es el otro consumidor de `ProductsBloc`, para confirmar que `initialLoadDone`/`searchProduct`/`searchProducts`/`updatePorduct` siguen compilando igual).

Run: `flutter test`
Expected: todos los tests en PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/src/bloc/productos_bloc.dart lib/src/page/producto/productos.page.dart
git commit -m "feat: agrega caché TTL a ProductsBloc y migra ProductosPage a ensureFresh/forceRefresh"
```

---

## Task 6: Verificación manual end-to-end

**Files:** ninguno (solo verificación).

**Interfaces:** ninguna — consume el resultado completo de las Tasks 1-5.

- [ ] **Step 1: Análisis y suite completa sobre el proyecto entero**

Run: `flutter analyze`
Expected: `No issues found!`

Run: `flutter test`
Expected: todos los tests en PASS (incluye los 9 tests nuevos/modificados de las Tasks 1 y 2, más toda la suite preexistente).

- [ ] **Step 2: Levantar la app y verificar los 4 escenarios del caché**

Correr la app en un simulador/dispositivo disponible (`flutter run`) e ir a las pantallas Clientes y Productos verificando:

1. **Caché frío (primera vez):** borrar datos de la app o usar un dispositivo limpio; al abrir Clientes/Productos debe verse el spinner de carga brevemente y luego la lista.
2. **Caché fresco:** volver a abrir la misma pantalla (navegar a otro tab y volver, o cerrar y reabrir la app) dentro de los primeros 30 min (clientes) / 15 min (productos); la lista debe aparecer de inmediato, sin spinner.
3. **Caché vencido:** con un TTL ya cumplido (se puede forzar temporalmente bajando el TTL a `Duration(seconds: 10)` en una build de prueba, o editando manualmente el valor `_savedAt` guardado), la lista debe mostrar de inmediato el valor cacheado y, sin parpadeo ni spinner, actualizarse silenciosamente si hay cambios en el servidor.
4. **Sin red:** con el dispositivo en modo avión y ya con caché guardado de una sesión anterior, la app debe mostrar el caché existente sin error visible (el fallo de red se ignora silenciosamente, según el manejo de errores del diseño).

- [ ] **Step 3: Reportar resultado**

Si los 4 escenarios se comportan como se espera, el plan queda completo. Si alguno falla, documentar el escenario y el comportamiento observado antes de dar la tarea por terminada.
