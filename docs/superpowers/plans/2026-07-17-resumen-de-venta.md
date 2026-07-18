# Resumen de Venta (móvil) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Agregar una opción "Resumen de Venta" al menú lateral (`Drawer`) de la app móvil Flutter, que muestre los totales agregados (cantidad, neto, descuentos, IVA, ILA, bruto) de las ventas en estado `FINISHED` del vendedor autenticado.

**Architecture:** Una clase pura `ResumenVentasCalculator` (sin I/O) calcula los totales a partir de una `List<VentaModel>`. `VentaProvider` gana un nuevo método `obtenerVentasPendientesFacturacion()` que llama `GET /api/ventas?estados=FINISHED` (mismo endpoint que ya usa la web) y filtra client-side por `codigoVendedor == PreferenciasUsuario().vendedor`. Una nueva página `ResumenDeVentasPage` conecta ambos con un `FutureBuilder`, siguiendo el mismo patrón visual que `ListadeDeVentasPage`. Se agrega al `Drawer` de `HomePage` como una pestaña más (mismo patrón swap-de-página que Ventas/Productos/Clientes/Configuración). Sin cambios de backend.

**Tech Stack:** Flutter/Dart, Dio para HTTP, `flutter_test` para pruebas unitarias (sin mocktail en este plan — ver Global Constraints).

## Global Constraints

- Alcance de datos: solo ventas del vendedor autenticado (`PreferenciasUsuario().vendedor`), estado `FINISHED` únicamente. Sin filtros de fecha/cliente/ruta.
- No modificar el backend Spring Boot.
- Sin botón de facturar ni edición: pantalla de solo lectura.
- `VentaProvider.obtenerVentasPendientesFacturacion()` debe **relanzar** los errores como `Exception` (no tragarlos como `obtenerListaVentas()`), siguiendo la convención documentada en `CLAUDE.md`: "Los providers lanzan `DioException`/`Exception`; la UI es responsable de capturar y mostrar los errores."
- No introducir inyección de dependencias nueva en `VentaProvider` solo para hacerla testeable — seguir el patrón existente del archivo (sus métodos de red no tienen test unitario directo hoy). El valor de testing se concentra en `ResumenVentasCalculator`, que es puro.
- Seguir la convención de nombres de archivo con puntos ya usada en `lib/src/page/ventas/` (`listado.de.ventas.page.dart`, etc.).
- Todo el texto de UI en español.
- Formato de moneda: usar `getValorModena(valor, 0)` (`lib/src/utils/utils.dart`), igual que el resto de la app.
- Spec de referencia: `docs/superpowers/specs/2026-07-17-resumen-de-venta-design.md`.
- Baseline verificado antes de este plan: `flutter test` → 26/26 pasan; `flutter analyze` → 0 errores, 48 issues preexistentes (info/warning) no relacionados con este trabajo — no se deben introducir errores nuevos ni se debe intentar arreglar los preexistentes.

---

### Task 1: `ResumenVentasCalculator` (lógica pura, TDD)

**Files:**
- Create: `lib/src/model/resumen_ventas_calculator.dart`
- Test: `test/unit/resumen_ventas_calculator_test.dart`

**Interfaces:**
- Consumes: `VentaModel` (`lib/src/model/venta_model.dart`), campos `totalNeto`, `totalDescuento`, `totalIva`, `totalIla`, `total` (todos `double`).
- Produces: clase `ResumenVentas` (campos públicos `final`: `cantidadVentas` (`int`), `totalNeto`, `totalDescuento`, `totalIva`, `totalIla`, `totalBruto` (todos `double`)) y clase `ResumenVentasCalculator` con método estático `ResumenVentas calcular(List<VentaModel> ventas)`. Task 2 (la página) usa exactamente esta firma y estos nombres de campo.

- [ ] **Step 1: Escribir el test (debe fallar — el archivo de producción no existe)**

Crea `test/unit/resumen_ventas_calculator_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/model/resumen_ventas_calculator.dart';

VentaModel _buildVenta({
  double totalNeto = 0,
  double totalDescuento = 0,
  double totalIva = 0,
  double totalIla = 0,
  double total = 0,
}) {
  return VentaModel(
    fecha: DateTime(2026, 7, 17),
    rutCliente: '11111111-1',
    codigoVendedor: 'V1',
    codigoRuta: 'R1',
    codigoCondicionVenta: 'CT',
    totalNeto: totalNeto,
    totalDescuento: totalDescuento,
    totalIva: totalIva,
    totalIla: totalIla,
    total: total,
  );
}

void main() {
  group('ResumenVentasCalculator', () {
    test('calcula cero con lista vacía', () {
      final resumen = ResumenVentasCalculator.calcular([]);

      expect(resumen.cantidadVentas, 0);
      expect(resumen.totalNeto, 0);
      expect(resumen.totalDescuento, 0);
      expect(resumen.totalIva, 0);
      expect(resumen.totalIla, 0);
      expect(resumen.totalBruto, 0);
    });

    test('suma los totales de varias ventas', () {
      final ventas = [
        _buildVenta(
            totalNeto: 1000,
            totalDescuento: 100,
            totalIva: 190,
            totalIla: 50,
            total: 1140),
        _buildVenta(
            totalNeto: 2000,
            totalDescuento: 0,
            totalIva: 380,
            totalIla: 100,
            total: 2480),
      ];

      final resumen = ResumenVentasCalculator.calcular(ventas);

      expect(resumen.cantidadVentas, 2);
      expect(resumen.totalNeto, 3000);
      expect(resumen.totalDescuento, 100);
      expect(resumen.totalIva, 570);
      expect(resumen.totalIla, 150);
      expect(resumen.totalBruto, 3620);
    });

    test('cuenta correctamente una sola venta', () {
      final resumen = ResumenVentasCalculator.calcular([
        _buildVenta(totalNeto: 500, total: 500),
      ]);

      expect(resumen.cantidadVentas, 1);
      expect(resumen.totalNeto, 500);
      expect(resumen.totalBruto, 500);
    });
  });
}
```

- [ ] **Step 2: Ejecutar el test y confirmar que falla**

Run: `flutter test test/unit/resumen_ventas_calculator_test.dart`
Expected: FAIL — error de compilación porque `lib/src/model/resumen_ventas_calculator.dart` no existe todavía (`Error: Error when reading 'lib/src/model/resumen_ventas_calculator.dart'` o similar "Target of URI doesn't exist").

- [ ] **Step 3: Implementar `ResumenVentasCalculator`**

Crea `lib/src/model/resumen_ventas_calculator.dart`:

```dart
import 'venta_model.dart';

class ResumenVentas {
  const ResumenVentas({
    required this.cantidadVentas,
    required this.totalNeto,
    required this.totalDescuento,
    required this.totalIva,
    required this.totalIla,
    required this.totalBruto,
  });

  final int cantidadVentas;
  final double totalNeto;
  final double totalDescuento;
  final double totalIva;
  final double totalIla;
  final double totalBruto;
}

class ResumenVentasCalculator {
  static ResumenVentas calcular(List<VentaModel> ventas) {
    return ResumenVentas(
      cantidadVentas: ventas.length,
      totalNeto: ventas.fold(0.0, (suma, venta) => suma + venta.totalNeto),
      totalDescuento:
          ventas.fold(0.0, (suma, venta) => suma + venta.totalDescuento),
      totalIva: ventas.fold(0.0, (suma, venta) => suma + venta.totalIva),
      totalIla: ventas.fold(0.0, (suma, venta) => suma + venta.totalIla),
      totalBruto: ventas.fold(0.0, (suma, venta) => suma + venta.total),
    );
  }
}
```

- [ ] **Step 4: Ejecutar el test y confirmar que pasa**

Run: `flutter test test/unit/resumen_ventas_calculator_test.dart`
Expected: PASS — los 3 tests pasan (`+3: All tests passed!`).

- [ ] **Step 5: Correr análisis estático**

Run: `flutter analyze lib/src/model/resumen_ventas_calculator.dart test/unit/resumen_ventas_calculator_test.dart`
Expected: sin errores (`No issues found!` o solo issues de estilo `info`, ninguno nuevo tipo `error`).

- [ ] **Step 6: Commit**

```bash
git add lib/src/model/resumen_ventas_calculator.dart test/unit/resumen_ventas_calculator_test.dart
git commit -m "feat: agrega ResumenVentasCalculator con totales agregados de ventas"
```

---

### Task 2: `VentaProvider.obtenerVentasPendientesFacturacion()` + `ResumenDeVentasPage`

**Files:**
- Modify: `lib/src/provider/venta_provider.dart`
- Create: `lib/src/page/ventas/resumen.de.ventas.page.dart`

**Interfaces:**
- Consumes: `ResumenVentasCalculator.calcular(List<VentaModel>)` → `ResumenVentas` (Task 1); `VentaModel` (`lib/src/model/venta_model.dart`); `PreferenciasUsuario().vendedor` (`lib/src/share/prefs_usuario.dart`); `getValorModena(double, int)` y `colorRojoBase()` (`lib/src/utils/utils.dart`); `AppScaffoldKey.homeKey` (`lib/src/share/app_scaffold_key.dart`).
- Produces: `VentaProvider.ventaProvider.obtenerVentasPendientesFacturacion()` → `Future<List<VentaModel>>` (lanza `Exception` en error). Clase pública `ResumenDeVentasPage` (widget `StatelessWidget`/`StatefulWidget` sin parámetros de constructor requeridos: `const ResumenDeVentasPage()`). Task 3 (menú) usa exactamente este nombre de clase y este constructor.

- [ ] **Step 1: Agregar el método al provider**

En `lib/src/provider/venta_provider.dart`, agrega este método dentro de la clase `VentaProvider`, inmediatamente después de `obtenerListaVentas()` (después del `}` que cierra ese método, antes de la documentación de `obtenerListaVentasDetalle`):

```dart
  Future<List<VentaModel>> obtenerVentasPendientesFacturacion() async {
    final prefs = PreferenciasUsuario();

    try {
      final response = await _dio.get(
        '/api/ventas',
        queryParameters: {
          'estados': ['FINISHED']
        },
      );

      final List<dynamic> data = response.data;
      final ventas = data.map((json) => VentaModel.fromMap(json)).toList();

      return ventas
          .where((venta) => venta.codigoVendedor == prefs.vendedor)
          .toList();
    } on DioException catch (e) {
      developer.log(
          "No se ha podido obtener el resumen de ventas pendientes de facturación",
          error: e);

      final statusCode = e.response?.statusCode;
      throw Exception(
          "Error al obtener el resumen de ventas pendientes de facturación. "
          "Status: $statusCode, Mensaje Dio: ${e.message}");
    }
  }
```

No se necesitan imports nuevos en este archivo: `PreferenciasUsuario`, `DioException`, `VentaModel` y `developer` ya están importados (usados por métodos existentes en el mismo archivo).

- [ ] **Step 2: Verificar que compila**

Run: `flutter analyze lib/src/provider/venta_provider.dart`
Expected: sin errores nuevos (`No issues found!` o solo los issues preexistentes ya documentados en Global Constraints, ninguno en este archivo).

- [ ] **Step 3: Crear la página `ResumenDeVentasPage`**

Crea `lib/src/page/ventas/resumen.de.ventas.page.dart`:

```dart
import 'package:dipalza_movil/src/model/resumen_ventas_calculator.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../share/app_scaffold_key.dart';

class ResumenDeVentasPage extends StatefulWidget {
  const ResumenDeVentasPage({Key? key}) : super(key: key);

  @override
  _ResumenDeVentasPageState createState() => _ResumenDeVentasPageState();
}

class _ResumenDeVentasPageState extends State<ResumenDeVentasPage> {
  late Future<List<VentaModel>> _ventasFuture;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  void _cargarResumen() {
    setState(() {
      _ventasFuture =
          VentaProvider.ventaProvider.obtenerVentasPendientesFacturacion();
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
        title: const Text(
          'Resumen de Venta',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _creaResumen(context),
    );
  }

  Widget _creaResumen(BuildContext context) {
    return FutureBuilder(
      future: _ventasFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<VentaModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
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
                  onPressed: _cargarResumen,
                  child: const Text("Reintentar"),
                )
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final resumen = ResumenVentasCalculator.calcular(snapshot.data!);
          return ListView(
            padding: const EdgeInsets.all(12.0),
            children: [
              _tarjetaResumen('Cantidad de Ventas',
                  resumen.cantidadVentas.toString(), Icons.list_alt),
              _tarjetaResumen('Total Neto',
                  getValorModena(resumen.totalNeto, 0), Icons.attach_money),
              _tarjetaResumen('Total Descuentos',
                  getValorModena(resumen.totalDescuento, 0), Icons.percent),
              _tarjetaResumen('Total IVA',
                  getValorModena(resumen.totalIva, 0), Icons.receipt_long),
              _tarjetaResumen('Total ILA',
                  getValorModena(resumen.totalIla, 0), Icons.request_quote),
              _tarjetaResumen('Total Bruto',
                  getValorModena(resumen.totalBruto, 0), Icons.payments),
            ],
          );
        } else {
          return const Center(child: Text("Sin información disponible"));
        }
      },
    );
  }

  Widget _tarjetaResumen(String titulo, String valor, IconData icono) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorRojoBase(),
          foregroundColor: Colors.white,
          child: Icon(icono),
        ),
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.normal)),
        trailing: Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Verificar que compila**

Run: `flutter analyze lib/src/page/ventas/resumen.de.ventas.page.dart`
Expected: sin errores (`No issues found!` o solo issues de estilo `info`, ninguno tipo `error`).

- [ ] **Step 5: Correr la suite completa de tests**

Run: `flutter test`
Expected: PASS — los 26 tests preexistentes más los 3 de `ResumenVentasCalculator` del Task 1 (`+29: All tests passed!`). Esta página nueva no tiene test propio (no hay forma de inyectar un `VentaProvider` simulado sin romper el patrón singleton existente en todo el archivo — ver Global Constraints), así que no debe agregar ni restar tests aquí.

- [ ] **Step 6: Commit**

```bash
git add lib/src/provider/venta_provider.dart lib/src/page/ventas/resumen.de.ventas.page.dart
git commit -m "feat: agrega VentaProvider.obtenerVentasPendientesFacturacion() y ResumenDeVentasPage"
```

---

### Task 3: Entrada en el menú lateral (`Drawer` de `HomePage`)

**Files:**
- Modify: `lib/src/page/home/home.page.dart`

**Interfaces:**
- Consumes: `ResumenDeVentasPage` (`lib/src/page/ventas/resumen.de.ventas.page.dart`, Task 2), constructor `const ResumenDeVentasPage()`.
- Produces: nada consumido por tareas posteriores (última pieza de la integración).

- [ ] **Step 1: Agregar el import**

En `lib/src/page/home/home.page.dart`, agrega este import junto a los demás imports de páginas de `ventas/` (después de la línea `import '../ventas/listado.detalle.de.una.venta.dart';`):

```dart
import '../ventas/resumen.de.ventas.page.dart';
```

- [ ] **Step 2: Agregar la página a `_pages`**

En la misma clase `_HomePageState`, agrega `const ResumenDeVentasPage()` como quinto elemento de la lista `_pages` (índice 4), después de `const ListadeDeVentasPage(),` y antes de `const ProductosPage(),`:

```dart
  final List<Widget> _pages = [
    const ListadeDeVentasPage(),
    const ResumenDeVentasPage(),
    const ProductosPage(),
    const ClientesPage(),
    const ConfiguracionPage(showMenuIcon: true),
  ];
```

**Importante:** insertar `ResumenDeVentasPage` en el índice 1 desplaza `ProductosPage` a índice 2, `ClientesPage` a índice 3 y `ConfiguracionPage` a índice 4. El `Drawer` (Step 3) debe usar estos mismos índices desplazados para que `selected` y `_navegar(...)` sigan apuntando a la página correcta — revisa que ningún otro `ListTile` del `Drawer` quede desalineado.

- [ ] **Step 3: Agregar el `ListTile` al `Drawer`**

En el mismo archivo, dentro del `Drawer`, reemplaza el bloque completo de `ListTile`s (desde `ListTile(leading: const Icon(Icons.shopping_cart)...` hasta el `ListTile` de "Configuración" inclusive) por:

```dart
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Ventas'),
                  selected: _currentIndex == 0,
                  onTap: () => _navegar(0),
                ),
                ListTile(
                  leading: const Icon(Icons.assessment),
                  title: const Text('Resumen de Venta'),
                  selected: _currentIndex == 1,
                  onTap: () => _navegar(1),
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Productos'),
                  selected: _currentIndex == 2,
                  onTap: () => _navegar(2),
                ),
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

- [ ] **Step 4: Verificar que compila**

Run: `flutter analyze lib/src/page/home/home.page.dart`
Expected: sin errores nuevos (`No issues found!` o solo issues de estilo `info` ya preexistentes en este archivo, ninguno tipo `error`).

- [ ] **Step 5: Correr la suite completa de tests**

Run: `flutter test`
Expected: PASS — mismos 29 tests que al final del Task 2 (`+29: All tests passed!`). Este cambio no agrega tests propios (es solo wiring de navegación, sin lógica nueva) y no debería romper ninguno de los existentes (`test/widget_test.dart` hace un smoke test de la app completa — confirma que sigue pasando).

- [ ] **Step 6: Verificación manual pendiente (documentar, no ejecutar aquí)**

Este entorno no tiene un emulador Android/iOS disponible para instalar y correr la app end-to-end con sesión real. Documenta explícitamente en el reporte de la tarea que queda pendiente que un humano, con `flutter run` en un dispositivo o emulador real y una sesión de vendedor autenticada, verifique visualmente:
1. Que el `Drawer` muestra "Resumen de Venta" debajo de "Ventas".
2. Que al tocarlo se abre `ResumenDeVentasPage` con las 6 tarjetas.
3. Que "Cantidad de Ventas" y los totales coinciden con lo que ese vendedor ve en la pantalla "Ventas" si filtrara mentalmente por las ventas ya finalizadas.
4. Que el botón "Reintentar" funciona si se corta la conexión.

No se debe declarar esta tarea como visualmente verificada sin que esto ocurra.

- [ ] **Step 7: Commit**

```bash
git add lib/src/page/home/home.page.dart
git commit -m "feat: agrega Resumen de Venta al menú lateral de la app móvil"
```
