# Últimas Ventas por Cliente (app móvil) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Agregar una opción de menú "Últimas Ventas" que permita elegir un cliente y ver sus últimas 3 ventas facturadas (fecha, neto, IVA, ILA, descuento, total), con acceso al detalle completo de cada una.

**Architecture:** Reutiliza casi todo lo existente: `ClientesPage(isForSelection: true)` como selector de cliente, `ListadoDetalleDeUltimaVentaPage` como pantalla de detalle (sin cambios), y el endpoint backend nuevo `POST /api/ventas/ultimasventascliente` (ya implementado por separado en `dipalza.springboot`, ver `docs/superpowers/plans/2026-07-18-ultimas-ventas-cliente.md` de ese repo). Lo nuevo acá: un método en `VentaProvider`, una página `UltimasVentasClientePage`, y su entrada en el drawer de `home.page.dart`.

**Tech Stack:** Flutter/Dart, `dio` (HTTP), mismos patrones ya usados en `VentaProvider`/`ResumenDeVentasPage`.

## Global Constraints

- Cantidad fija en 3 ventas (no configurable).
- Solo ventas facturadas (el backend ya filtra por `estado = 'CLOSED'` — no hay nada que filtrar del lado Flutter).
- `UltimasVentasClientePage` y el nuevo método de `VentaProvider` no llevan test unitario (ver spec, sección Testing) — mismo criterio que se usó para `ClientesBloc`/`ProductsBloc`/los providers en el trabajo de caché: sin precedente de test para providers Dio en este código, y esta pantalla depende de un flujo de navegación real. Se verifica con `flutter analyze` + `flutter test` (suite completa) + verificación manual.
- No se modifica `ClientesPage` (el ícono de "última venta" por fila queda igual), ni `ListadoDetalleDeUltimaVentaPage`.

Spec de referencia: `docs/superpowers/specs/2026-07-18-ultimas-ventas-cliente-design.md`

---

## File Structure

- **Modify:** `lib/src/provider/venta_provider.dart` — agrega `obtenerUltimasVentasDeCliente`.
- **Create:** `lib/src/page/ventas/ultimas.ventas.cliente.page.dart` — `UltimasVentasClientePage`.
- **Modify:** `lib/src/page/home/home.page.dart` — agrega el import, la página a `_pages`, la entrada al drawer, y renumera `Configuración`.

---

## Task 1: `VentaProvider.obtenerUltimasVentasDeCliente`

**Files:**
- Modify: `lib/src/provider/venta_provider.dart`

**Interfaces:**
- Produces: `VentaProvider.obtenerUltimasVentasDeCliente(ClientesModel cliente): Future<List<VentaModel>>` — usado por la Task 2.
- Consumes: `POST /api/ventas/ultimasventascliente` (backend, ya implementado por separado).

- [ ] **Step 1: Agregar el método**

En `lib/src/provider/venta_provider.dart`, agregar inmediatamente después de `obtenerUltimaVenta` (después del cierre de ese método, antes de `cambiarEstadoVenta`):

```dart
  Future<List<VentaModel>> obtenerUltimasVentasDeCliente(
      ClientesModel cliente) async {
    try {
      final clientIdQuery = {"rut": cliente.rut, "codigo": cliente.codigo};
      final response = await _dio.post('/api/ventas/ultimasventascliente',
          data: jsonEncode(clientIdQuery));

      final List<dynamic> data = response.data;
      return data.map((json) => VentaModel.fromMap(json)).toList();
    } on DioException catch (e) {
      developer.log(
        "Error técnico al obtener últimas ventas de ${cliente.razon}",
        error: e,
      );
      throw Exception(
          "Error de comunicación con el servidor (Código: ${e.response?.statusCode})");
    }
  }
```

(No se necesitan imports nuevos: `dart:convert` (`jsonEncode`), `dart:developer as developer`, `ClientesModel`, `VentaModel`, `DioException` ya están importados en este archivo — es el mismo patrón que `obtenerUltimaVenta`, unas líneas más arriba.)

- [ ] **Step 2: Verificar que analiza limpio**

Run: `flutter analyze lib/src/provider/venta_provider.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/provider/venta_provider.dart
git commit -m "feat: agrega VentaProvider.obtenerUltimasVentasDeCliente"
```

---

## Task 2: Página `UltimasVentasClientePage`

**Files:**
- Create: `lib/src/page/ventas/ultimas.ventas.cliente.page.dart`

**Interfaces:**
- Consumes: `VentaProvider.obtenerUltimasVentasDeCliente` (Task 1), `AppRoutes.clientesSeleccion` (selector de cliente existente), `AppRoutes.listadoUltimaVenta` (detalle existente, sin cambios).
- Produces: `UltimasVentasClientePage` (StatefulWidget, sin parámetros) — usado por la Task 3 en `home.page.dart`.

- [ ] **Step 1: Crear la página**

Crear `lib/src/page/ventas/ultimas.ventas.cliente.page.dart`:

```dart
import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/app.formatter.dart';
import 'package:dipalza_movil/src/share/app.navigator.dart';
import 'package:dipalza_movil/src/share/app_routes.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../share/app_scaffold_key.dart';

class UltimasVentasClientePage extends StatefulWidget {
  const UltimasVentasClientePage({Key? key}) : super(key: key);

  @override
  _UltimasVentasClientePageState createState() =>
      _UltimasVentasClientePageState();
}

class _UltimasVentasClientePageState extends State<UltimasVentasClientePage> {
  ClientesModel? _cliente;
  Future<List<VentaModel>>? _ventasFuture;

  @override
  void initState() {
    super.initState();
    _seleccionarCliente();
  }

  Future<void> _seleccionarCliente() async {
    final cliente = await AppNavigator.pushNamed<ClientesModel>(
        AppRoutes.clientesSeleccion);
    if (cliente == null) return;
    setState(() {
      _cliente = cliente;
      _ventasFuture =
          VentaProvider.ventaProvider.obtenerUltimasVentasDeCliente(cliente);
    });
  }

  void _reintentar() {
    if (_cliente == null) return;
    setState(() {
      _ventasFuture = VentaProvider.ventaProvider
          .obtenerUltimasVentasDeCliente(_cliente!);
    });
  }

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
        backgroundColor: colorRojoBase(),
        title: Text(
          _cliente == null ? 'Últimas Ventas' : _cliente!.razon,
          style: const TextStyle(color: Colors.white),
        ),
        actions: _cliente == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.person_search),
                  tooltip: 'Cambiar cliente',
                  onPressed: _seleccionarCliente,
                ),
              ],
      ),
      body: _cliente == null ? _creaSinCliente() : _creaConCliente(),
    );
  }

  Widget _creaSinCliente() {
    return Center(
      child: ElevatedButton(
        onPressed: _seleccionarCliente,
        child: const Text('Seleccionar Cliente'),
      ),
    );
  }

  Widget _creaConCliente() {
    return FutureBuilder<List<VentaModel>>(
      future: _ventasFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<VentaModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 10),
                const Text('Ocurrió un error al cargar:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: _reintentar,
                  child: const Text('Reintentar'),
                )
              ],
            ),
          );
        }
        final ventas = snapshot.data ?? [];
        if (ventas.isEmpty) {
          return const Center(
            child: Text('Este cliente no tiene ventas facturadas.'),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(12.0),
          children: ventas.map((venta) => _tarjetaVenta(venta)).toList(),
        );
      },
    );
  }

  Widget _tarjetaVenta(VentaModel venta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => AppNavigator.pushNamed(AppRoutes.listadoUltimaVenta,
            arguments: {'ventaModel': venta}),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 8),
                  Text(
                    AppFormatters.formatoFecha.format(venta.fecha),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Divider(),
              _filaMonto('Neto', venta.totalNeto),
              _filaMonto('IVA', venta.totalIva),
              _filaMonto('ILA', venta.totalIla),
              _filaMonto('Descuento', venta.totalDescuento),
              _filaMonto('Total', venta.total, destacado: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaMonto(String etiqueta, double valor, {bool destacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(etiqueta,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const Spacer(),
          Text(
            AppFormatters.formatoMoneda.format(valor),
            style: TextStyle(
              fontSize: destacado ? 16 : 14,
              fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verificar que analiza limpio**

Run: `flutter analyze lib/src/page/ventas/ultimas.ventas.cliente.page.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/page/ventas/ultimas.ventas.cliente.page.dart
git commit -m "feat: agrega UltimasVentasClientePage"
```

---

## Task 3: Integrar al menú de `home.page.dart`

**Files:**
- Modify: `lib/src/page/home/home.page.dart`

**Interfaces:**
- Consumes: `UltimasVentasClientePage` (Task 2).

- [ ] **Step 1: Agregar el import**

En `lib/src/page/home/home.page.dart`, agregar junto a los demás imports de `../ventas/`:

```dart
import '../ventas/ultimas.ventas.cliente.page.dart';
```

- [ ] **Step 2: Agregar la página a `_pages` y renumerar**

Reemplazar:

```dart
  final List<Widget> _pages = [
    const ListadeDeVentasPage(),
    const ResumenDeVentasPage(),
    const ProductosPage(),
    const ClientesPage(),
    const ConfiguracionPage(showMenuIcon: true),
  ];
```

por:

```dart
  final List<Widget> _pages = [
    const ListadeDeVentasPage(),
    const ResumenDeVentasPage(),
    const ProductosPage(),
    const ClientesPage(),
    const UltimasVentasClientePage(),
    const ConfiguracionPage(showMenuIcon: true),
  ];
```

- [ ] **Step 3: Agregar la entrada al drawer y renumerar Configuración**

Reemplazar:

```dart
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Clientes'),
                  selected: _currentIndex == 3,
                  onTap: () => _navegar(3),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configuración'),
                  selected: _currentIndex == 4,
                  onTap: () => _navegar(4),
                ),
```

por:

```dart
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Clientes'),
                  selected: _currentIndex == 3,
                  onTap: () => _navegar(3),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Últimas Ventas'),
                  selected: _currentIndex == 4,
                  onTap: () => _navegar(4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configuración'),
                  selected: _currentIndex == 5,
                  onTap: () => _navegar(5),
                ),
```

- [ ] **Step 4: Verificar que el proyecto analiza limpio y la suite completa pasa**

Run: `flutter analyze`
Expected: mismos issues preexistentes de antes de este trabajo (ver plan de caché) — ninguno nuevo en `home.page.dart`, `venta_provider.dart` o `ultimas.ventas.cliente.page.dart`.

Run: `flutter test`
Expected: todos los tests en PASS (este trabajo no agrega tests nuevos, así que el conteo no cambia respecto al estado previo).

- [ ] **Step 5: Build de verificación**

Run: `flutter build ios --debug --simulator`
Expected: `✓ Built build/ios/iphonesimulator/Runner.app` — confirma que la nueva página y el wiring del drawer compilan de punta a punta.

- [ ] **Step 6: Commit**

```bash
git add lib/src/page/home/home.page.dart
git commit -m "feat: agrega Últimas Ventas al menú lateral"
```

---

## Verificación manual pendiente (requiere login real)

Igual que quedó documentado para el caché: abrir la app con un usuario real, tocar "Últimas Ventas" en el menú, confirmar que abre el selector de cliente automáticamente, elegir un cliente con ventas facturadas, verificar que las tarjetas muestran fecha/neto/IVA/ILA/descuento/total correctos, tocar una tarjeta y confirmar que abre el detalle correcto. Probar también un cliente sin ventas facturadas (mensaje de lista vacía) y el botón "Cambiar cliente".
