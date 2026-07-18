# Últimas Ventas por Cliente (nueva opción de menú)

**Fecha:** 2026-07-18
**Motivación:** agregar una opción de menú en la app móvil que permita elegir un cliente y ver sus últimas 3 ventas (fecha, neto, IVA, ILA, descuento, total final), con acceso al detalle completo de cada una.

## Contexto y reutilización

Ya existe casi toda la infraestructura necesaria:

- **Selector de cliente:** `ClientesPage(isForSelection: true)`, ruta `AppRoutes.clientesSeleccion`. Al tocar un cliente hace `AppNavigator.pop(cliente)` (`lib/src/page/cliente/clientes.page.dart`), así que `AppNavigator.pushNamed<ClientesModel>(AppRoutes.clientesSeleccion)` devuelve el cliente elegido (o `null` si el usuario vuelve atrás sin elegir).
- **Detalle de una venta:** `ListadoDetalleDeUltimaVentaPage`, ruta `AppRoutes.listadoUltimaVenta`, recibe `{'ventaModel': VentaModel}` y ya muestra condición de venta, descuento, neto, fecha, y el detalle de ítems (`VentaProvider.obtenerListaVentasDetalle`). **No se modifica.**
- **Backend:** `VentaService.obtenerUltimaVentaDeCliente` (`VentaController` `POST /api/ventas/ultimaventacliente`) ya trae la última venta *cerrada* (facturada, `estado = 'CLOSED'`) de un cliente vía `ventaRepository.findVentasCerradasByClienteOrderByFechaDesc(rut, codigo, PageRequest.of(0, 1))`, más reciente primero. Extender esto a 3 es cambiar el `PageRequest` y devolver una lista.
- **Campos:** `VentaModel`/`VentaDTO` ya tienen `fecha`, `totalNeto`, `totalIva`, `totalIla`, `totalDescuento`, `total` — exactamente los 6 campos pedidos (los 5 montos + fecha).

Lo único nuevo: un endpoint que devuelva 3 ventas en vez de 1, y una pantalla que arme las 3 tarjetas y navegue al detalle ya existente.

## Alcance

- Nueva opción de menú "Últimas Ventas" en la app móvil (`flutterDipalza`), entre "Clientes" y "Configuración".
- Backend: nuevo endpoint que devuelve hasta 3 ventas cerradas de un cliente (mismo criterio — `estado = 'CLOSED'` — que la última venta ya usa).
- **Fuera de alcance:** cambiar el ícono "ver última venta" que ya existe por fila en `ClientesPage` (se mantiene tal cual, mostrando 1 venta); cambiar `ListadoDetalleDeUltimaVentaPage`; hacer configurable la cantidad de ventas (queda fija en 3, como se pidió); cliente web Angular (confirmado: esto es solo para la app móvil).

## Diseño

### Backend (`dipalza.springboot`)

- `VentaService.obtenerUltimasVentasDeCliente(ClienteIdQueryDTO params)`: mismo cuerpo que `obtenerUltimaVentaDeCliente`, pero `PageRequest.of(0, 3)` y devuelve `List<VentaDTO>` (lista vacía si el cliente no tiene ventas cerradas — no hace falta manejar "no encontrado" como caso especial, a diferencia del endpoint singular).
- `VentaController`: nuevo `POST /api/ventas/ultimasventascliente`, mismo `@RequestBody ClienteIdQueryDTO`, siempre `200 OK` con la lista (posiblemente vacía).

### Flutter (`flutterDipalza`)

- `VentaProvider.obtenerUltimasVentasDeCliente(ClientesModel cliente)`: mismo patrón que `obtenerUltimaVenta` (POST con `{rut, codigo}`), pero al endpoint plural, devolviendo `List<VentaModel>` (propaga la excepción en error técnico, igual que `obtenerUltimaVenta` ya hace — no hay caso 404 que tratar como "vacío", el backend ya devuelve `[]`).
- Página nueva `UltimasVentasClientePage` (`lib/src/page/ventas/ultimas.ventas.cliente.page.dart`):
  - Estado interno: `_cliente` (`ClientesModel?`, empieza `null`) y `_ventasFuture` (`Future<List<VentaModel>>?`).
  - En `initState`, llama directamente `AppNavigator.pushNamed<ClientesModel>(AppRoutes.clientesSeleccion)` para abrir el selector de cliente (no hace falta esperar al primer frame: `AppNavigator` usa `navigatorKey.currentState`, no el `BuildContext` local, así que es seguro invocarlo desde `initState`). Si devuelve un cliente, lo guarda y dispara la carga de sus últimas 3 ventas. Si devuelve `null` (el usuario volvió sin elegir), queda en el estado "sin cliente".
  - **Sin cliente seleccionado:** cuerpo centrado con un botón "Seleccionar Cliente" que vuelve a abrir el selector (mismo método que en `initState`).
  - **Con cliente seleccionado:** AppBar muestra el nombre del cliente (`_cliente!.razon`) y un ícono de acción para cambiar de cliente (reabre el selector). Cuerpo: `FutureBuilder<List<VentaModel>>` — loading (spinner), error (ícono + mensaje + botón "Reintentar", mismo patrón que `ResumenDeVentasPage`), lista vacía ("Este cliente no tiene ventas facturadas."), o hasta 3 tarjetas.
  - Cada tarjeta muestra: fecha (`AppFormatters.formatoFecha`), y los 5 montos (`AppFormatters.formatoMoneda`) con etiqueta corta — Neto, IVA, ILA, Descuento, Total. Al tocar una tarjeta: `AppNavigator.pushNamed(AppRoutes.listadoUltimaVenta, arguments: {'ventaModel': venta})`.
- Sin constante nueva en `AppRoutes` ni entrada en `AppRouter.generateRoute`: la pantalla se agrega directamente a `_pages` en `home.page.dart`, igual que `ResumenDeVentasPage` (que tampoco tiene constante de ruta ni caso en el router — se instancia directo en la lista de tabs).
- `home.page.dart`: se agrega el import, un nuevo elemento en `_pages` (índice 4, después de `ClientesPage`, antes de `ConfiguracionPage`), un nuevo `ListTile` en el drawer ("Últimas Ventas", ícono `Icons.history`), y se renumera `Configuración` de índice 4 a 5.

## Manejo de errores

- Falla al cargar el selector de cliente: no aplica (la propia `ClientesPage` ya maneja sus errores de red vía su `StreamBuilder`/caché).
- Falla al pedir las últimas 3 ventas: mismo patrón que `ResumenDeVentasPage` — ícono de error, mensaje, botón "Reintentar" que vuelve a llamar al provider para el mismo cliente (sin volver a abrir el selector).

## Testing

- Backend: extender `VentaControllerTest` (patrón `@WebMvcTest` + `MockMvc` + `@MockBean VentaService`, ya usado en ese archivo) con un test para `POST /api/ventas/ultimasventascliente` que verifica que devuelve la lista que retorna el service mockeado.
- Flutter: sin test unitario para `UltimasVentasClientePage` ni para el nuevo método de `VentaProvider`, por la misma razón que `ClientesBloc`/`ProductsBloc` no los llevaron en el trabajo de caché — es un provider Dio sin punto de inyección para mockear, sin precedente de test en este código, y la pantalla depende de un flujo de navegación real (`AppNavigator`) difícil de aislar sin introducir un mecanismo de DI que el resto de la app no usa. Se verifica manualmente: `flutter analyze` + `flutter test` (suite completa) confirman que compila y no rompe nada existente; el flujo de selección→3 ventas→detalle se prueba a mano en el simulador/dispositivo, igual que quedó pendiente para el caché.

## Fuera de alcance

- Modificar el ícono de "última venta" por fila en `ClientesPage`.
- Cambios a `ListadoDetalleDeUltimaVentaPage`.
- Cantidad de ventas configurable (queda fija en 3).
- Cliente web Angular.
