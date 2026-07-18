# Resumen de Venta (móvil)

## Contexto

La app móvil Flutter ("Dipalza Móvil") es usada por vendedores de campo y ya tiene una pantalla "Ventas" (`ListadeDeVentasPage`) accesible desde el menú lateral (`Drawer` de `HomePage`, `lib/src/page/home/home.page.dart`). Esa pantalla lista, para el vendedor autenticado, las ventas en estado `OPENED` (en creación) del día de facturación vigente, vía `GET /api/ventas/vendedor/{codigo}/fecha` (hardcodeado a `OPENED` en el backend).

En paralelo, el cliente web (Angular) ya tiene una pantalla "Resumen de Venta" (ver `dipalzaSpringbootClient`) que muestra los totales agregados (cantidad, neto, descuentos, IVA, ILA, bruto) de las ventas en estado `FINISHED` ("el vendedor confirma la venta, queda lista para ser facturada"). Se pidió el mismo resumen en la app móvil.

## Objetivo

Agregar una nueva opción "Resumen de Venta" al menú lateral (`Drawer`) de la app móvil, que muestre los totales agregados de las ventas del vendedor autenticado que están en estado `FINISHED` (confirmadas por él, pendientes de ser facturadas):

- Cantidad de ventas
- Total Neto
- Total Descuentos
- Total IVA
- Total ILA
- Total Bruto

Alcance confirmado con el usuario: solo las ventas del vendedor que tiene la sesión abierta en el celular (no de toda la empresa), y solo estado `FINISHED` (no `OPENED`, que es lo que ya muestra la pantalla "Ventas" actual).

## Enfoque

Reutilizar el endpoint general `GET /api/ventas` (el mismo que usa la versión web) con el filtro `estados=FINISHED`, sin modificar el backend. El backend no expone un filtro por vendedor en este endpoint general, así que la app filtra en el cliente Dart, quedándose solo con las ventas cuyo `codigoVendedor` coincide con `PreferenciasUsuario().vendedor` (el vendedor de la sesión actual).

Se descartaron dos alternativas:
- **Filtrar por vendedor en el servidor** vía `GET /api/ventas/optimized?estados=FINISHED&codigosVendedores=<código>` (el backend tiene `VentaFilter.codigosVendedores`, y el endpoint `/optimized` lo expone vía `@ModelAttribute`): sería más eficiente y evitaría transferir ventas de otros vendedores al teléfono, pero no se pudo verificar en este entorno si el binding de Spring realmente completa un `record` con `@ModelAttribute` desde query params. Queda como mejora futura si se confirma que funciona.
- **Reusar el endpoint que ya usa la pantalla "Ventas"** (`GET /api/ventas/vendedor/{codigo}/fecha`): descartado porque el backend lo tiene hardcodeado a `EstadoVenta.OPENED`, y cambiarlo requeriría modificar el backend.

Dado que la filtración por vendedor ocurre en el cliente después de traer los datos, este endpoint transfiere al teléfono los totales de ventas `FINISHED` de todos los vendedores (no solo los propios) antes de descartarlos localmente. No es una capacidad nueva (el mismo JWT ya podría consultar ese endpoint directamente), pero es una transferencia de datos más amplia de la estrictamente necesaria; se documenta como conocido y aceptado para esta iteración.

## Diseño

### `VentaProvider` — nuevo método

En `lib/src/provider/venta_provider.dart`, nuevo método `obtenerVentasPendientesFacturacion()`:
- Llama `GET /api/ventas` con `queryParameters: {'estados': ['FINISHED']}`.
- Filtra la lista resultante quedándose solo con `venta.codigoVendedor == PreferenciasUsuario().vendedor`.
- Retorna `Future<List<VentaModel>>`.
- A diferencia de `obtenerListaVentas()` (que atrapa `DioException` y devuelve `[]` silenciosamente), este método **relanza** la excepción como `Exception` con un mensaje descriptivo, siguiendo la convención documentada en `CLAUDE.md` ("Los providers lanzan `DioException`/`Exception`; la UI es responsable de capturar y mostrar los errores"). Esto permite que la nueva pantalla muestre un estado de error real en vez de una lista vacía silenciosa cuando hay un problema de red — relevante porque son totales de dinero, no un listado navegable.

### Nueva clase pura `ResumenVentasCalculator`

Nuevo archivo `lib/src/model/resumen_ventas_calculator.dart` (junto a los demás modelos), sin dependencias de red ni de Flutter widgets:
- Método estático que recibe `List<VentaModel>` y retorna un objeto (o record) con: `cantidadVentas` (int), `totalNeto`, `totalDescuento`, `totalIva`, `totalIla`, `totalBruto` (todos `double`, sumando el campo `total` de cada venta como bruto).
- Con lista vacía, todos los totales son 0.
- Se testea con `flutter test` sin mocks (entrada y salida son datos puros).

### Nueva página `ResumenDeVentasPage`

Nuevo archivo `lib/src/page/ventas/resumen.de.ventas.page.dart` (seguir la convención de nombres con puntos ya usada en `ventas/`), siguiendo el mismo patrón de `ListadeDeVentasPage`:
- `AppBar` con botón de menú (abre el `Drawer` vía `AppScaffoldKey.homeKey`), fondo `colorRojoBase()`, título "Resumen de Venta".
- `FutureBuilder<List<VentaModel>>` sobre `VentaProvider.ventaProvider.obtenerVentasPendientesFacturacion()`:
  - `ConnectionState.waiting` → `CircularProgressIndicator` centrado.
  - `snapshot.hasError` → mismo bloque de error que `ListadeDeVentasPage` (ícono, mensaje, botón "Reintentar" que vuelve a disparar el `Future`).
  - `snapshot.hasData` → pasa la lista a `ResumenVentasCalculator`, y muestra 6 `Card`s (una por cada total) con el valor formateado vía `getValorModena(valor, 0)` para los 5 montos monetarios, y el número simple para "Cantidad de Ventas".
- Sin botón de facturar ni edición: pantalla de solo lectura, igual que su equivalente web.

### Menú lateral (`Drawer` de `HomePage`)

En `lib/src/page/home/home.page.dart`:
- Se agrega `const ResumenDeVentasPage()` a la lista `_pages` (índice 4).
- Se agrega un `ListTile` nuevo al `Drawer`, con ícono `Icons.assessment`, texto "Resumen de Venta", `selected: _currentIndex == 4`, `onTap: () => _navegar(4)` — mismo patrón que las entradas existentes (Ventas, Productos, Clientes), colocado después de "Ventas" y antes del `Divider()` que precede a "Configuración".
- No se toca `AppRoutes` ni `AppRouter.generateRoute()`: estas pestañas del `Drawer` no navegan por rutas con nombre, se intercambian directamente vía `_currentIndex` dentro de `HomePage`, igual que las demás.
- `HomePageBarraInferior` (variante con barra inferior) no está enrutada en `AppRouter` (no es la pantalla de inicio activa) — no se modifica.

## Fuera de alcance

- No se modifica el backend Spring Boot.
- No se agrega filtro por fecha/cliente/ruta en esta pantalla: siempre son todas las ventas `FINISHED` del vendedor autenticado.
- No se agrega la posibilidad de facturar ni editar desde esta pantalla.
- No se modifica `HomePageBarraInferior` (variante sin uso actual).
- No se introduce inyección de dependencias nueva en `VentaProvider` solo para hacerlo testeable — se sigue el patrón existente del archivo (métodos de red sin test unitario directo); el valor de testing se concentra en `ResumenVentasCalculator`, que sí es 100% puro y testeable.
