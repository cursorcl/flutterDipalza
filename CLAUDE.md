# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Descripción del Proyecto

Aplicación móvil Flutter para gestión de ventas ("Dipalza Móvil") — utilizada por vendedores de campo para crear/gestionar ventas, rastrear ubicación GPS, administrar clientes y productos. Orientada a Android e iOS. El backend se comunica mediante una API REST con autenticación JWT.

## Comandos Frecuentes

```bash
# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run

# Análisis estático
dart analyze

# Ejecutar pruebas
flutter test

# Ejecutar un archivo de prueba específico
flutter test test/unit/jwt_util_test.dart

# Regenerar íconos del lanzador y splash (después de cambiar assets)
flutter pub run flutter_launcher_icons:main
flutter pub run flutter_native_splash:create
```

## Arquitectura

La app utiliza tres patrones superpuestos — entender cuál aplica en cada lugar es fundamental:

### 1. BLoC (RxDart) — `lib/src/bloc/`
Usado para validación de formularios y lógica de negocio compleja. Streams mediante `BehaviorSubject`, validación de entradas mediante `StreamTransformer`. Los Blocs deben ser eliminados manualmente. El mixin `LoginBloc` + `LoginValidacion` es el ejemplo canónico.

### 2. Provider (ChangeNotifier) — registrado en `main.dart`
Usado para estado compartido a nivel de app (`ConnectivityService`). Envuelve todo el árbol de widgets mediante `MultiProvider`.

### 3. GetIt Service Locator — `lib/src/services/locator.dart`
Usado para singletons costosos (`ApiClient`, `CondicionVentaBloc`). Inicializado mediante `setupLocator()` al arrancar la app. Acceso mediante `locator<ApiClient>()`.

### Flujo de Datos
```
Páginas UI → BLoCs / Clases de datos Provider → lib/src/provider/ (capa API) → ApiClient (Dio) → Servidor
                                                                              → PreferenciasUsuario (SharedPrefs + SecureStorage)
```

### Autenticación y Gestión de Tokens
`ApiClient` (`lib/src/services/api_client.dart`) maneja todo HTTP mediante Dio con un interceptor en cola:
- En 401/403 → renovación silenciosa automática del token mediante `/auth/refresh`
- Múltiples solicitudes en vuelo durante la renovación se encolan (no se encadenan) para evitar el agotamiento de tokens
- Al expirar la sesión real → el stream `onSessionExpired` dispara → `MyApp` llama a `prefs.borrarCredenciales()` y redirige al login
- Los tokens se almacenan en dos capas: caché en memoria (acceso síncrono) + `FlutterSecureStorage` (encriptado asíncrono)

`PreferenciasUsuario` (`lib/src/share/prefs_usuario.dart`) es un singleton que combina:
- `FlutterSecureStorage` para tokens
- `SharedPreferences` para configuración (URL del servidor, ID del vendedor, tasa de IVA, ruta)

### Secuencia de arranque (`AuthGate`)
`AuthGate` actúa como splash screen. Al montar ejecuta `_bootstrap()`:
1. Espera 2 s (muestra logo)
2. Valida permisos GPS
3. Comprueba `refreshToken` en `PreferenciasUsuario`
4. Si el token existe y no expiró → llama a `ApiClient.renovarToken()` para renovación silenciosa
5. Si la sesión es válida → navega a `AppRoutes.home`; si no → `borrarCredenciales()` + navega a login

### Navegación
Navigator 1.0 con rutas nombradas. Todas las rutas definidas en `lib/src/share/app_routes.dart`, mapeadas en `AppRouter.generateRoute()` (`lib/src/share/app_router.dart`). La navegación pasa por `AppNavigator` que mantiene una `NavigatorKey` global — esto permite navegar desde fuera del árbol de widgets (p.ej., desde `ApiClient` al expirar la sesión).

### Servicio GPS en Segundo Plano
Corre en un **isolate separado** mediante `flutter_background_service`. Al estar aislado, no puede acceder al contenedor DI de la app principal — re-instancia `ApiClient` y `PreferenciasUsuario` de forma independiente. La ubicación se consulta cada 30 segundos mediante `Timer.periodic` (misma lógica en Android e iOS) y se envía mediante POST a `/api/posicion`.

### Sistema de Logging Local
`DBLogProvider` (`lib/src/log/db_log_provider.dart`) es un singleton que persiste logs en SQLite (`EmmaLogDB.db`). Usar las funciones de fábrica en `log_util.dart`:
- `creaLogInfo(clase, metodo, info)` → crea `LogModel` de tipo INFO
- `creaLogError(clase, metodo, info)` → crea `LogModel` de tipo ERROR

Los logs se consultan paginados y se visualizan en `console_log.page.dart`.

### Ciclo de Vida de una Venta
`EstadoVenta` (`lib/src/share/estado.venta.dart`) tiene cuatro estados:
- `OPENED` — en creación
- `FINISHED` — el vendedor terminó de ingresarla
- `REOPENED` — en modificación
- `CLOSED` — transferida al sistema externo, solo lectura

**Quirk conocido:** la API envía `'OPEND'` (sin la `E` final) para el estado abierto; `estadoVentaFromApi()` lo maneja.

## Convenciones Clave

- **Eliminación de BLoC:** Siempre asegurarse de cerrar los controladores `BehaviorSubject`. Al agregar un BLoC, registrar su llamada `dispose()` en la lista `MultiProvider` de `main.dart`.
- **Errores de API:** Los providers lanzan `DioException` / `Exception`; la UI es responsable de capturar y mostrar los errores.
- **Validadores:** La validación de formularios vive en `lib/src/validacion/` como mixins `StreamTransformer` — reutilizarlos en vez de validar en línea.
- **Pruebas:** Usar `mocktail` para mocking. Mockear `Dio` y las clases provider; no mockear `PreferenciasUsuario` directamente (es un singleton — preferir inyección de dependencias en las pruebas).
- **Nomenclatura en español:** El código base está en español (nombres de variables, comentarios, rutas). Seguir las convenciones de nomenclatura existentes al agregar código.
- **ID de aplicación Android:** El package ID fue cambiado a `cl.eosorio.dipalza.movil` (antes `com.example.dipalza_movil`). Tener esto en cuenta al configurar Firebase, signing, o permisos del dispositivo.

## Calidad del Código

`analysis_options.yaml` aplica reglas de `dart_code_metrics`:
- Complejidad ciclomática máxima: 20
- Nivel de anidamiento máximo: 5

Ejecutar `dart analyze` antes de enviar cambios.
