# Arquitectura del Proyecto Dipalza Móvil

## 1. Visión General de la Arquitectura

El proyecto sigue una arquitectura **hibrida** que combina:

- **Patrón Provider** para gestión de estado global
- **BLoC (Business Logic Component)** para lógica de negocio compleja
- **Service Locator** para inyección de dependencias
- **Clean Architecture** simplificada (separación UI/Lógica/Datos)

## 2. Capas de la Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  (Pages, Widgets, BLoCs, Providers)                    │
├─────────────────────────────────────────────────────────┤
│                    DOMAIN                                 │
│  (Models, Validations, Utils)                          │
├─────────────────────────────────────────────────────────┤
│                    DATA                                  │
│  (API Client, Local Storage, Services)                 │
└─────────────────────────────────────────────────────────┘
```

## 3. Flujo de Datos

### 3.1 Autenticación

```
LoginPage → LoginBloc (validación) → LoginProvider → ApiClient → Server
                ↓
         AuthGate (valida token)
                ↓
         HomePage (si autenticado)
```

### 3.2 Creación de Venta

```
HomePage → VentaEncabezadoEdicionPage → VentaProvider
                                              ↓
                                        ApiClient
                                              ↓
                                          Server
```

## 4. Componentes Principales

### 4.1 Providers (Estado Global)

| Provider | Responsabilidad |
|----------|-----------------|
| `LoginProvider` | Provee acceso al LoginBloc |
| `CondicionVentaBloc` | Gestión de condiciones de venta |
| `VentaProvider` | Lógica de ventas |
| `ClienteProvider` | Gestión de clientes |
| `ProductoProvider` | Catálogo de productos |
| `VendedorProvider` | Datos del vendedor actual |
| `RutasProvider` | Rutas asignadas |
| `ConduccionProvider` | Modalidades de conducción |
| `ParametrosProvider` | Parámetros globales |

### 4.2 BLoCs (Lógica de Negocio)

| BLoC | Funcionalidad |
|------|---------------|
| `LoginBloc` | Validación de formulario de login |
| `ProductosBloc` | Gestión de productos |
| `ProductosVentaBloc` | Productos en una venta |
| `RutasBloc` | Rutas del vendedor |
| `CondicionVentaBloc` | Condiciones de venta disponibles |

### 4.3 Servicios

| Servicio | Función |
|----------|---------|
| `ApiClient` | Cliente HTTP con interceptores (Dio) |
| `ConnectivityService` | Monitoreo de conexión a internet |
| `Locator` | Service Locator (GetIt) |

### 4.4 Modelos Principales

- **ClienteModel** - Datos del cliente (RUT, razón social, dirección)
- **ProductoModel** - Catálogo de productos
- **VentaModel** - Encabezado de venta
- **VentaDetalleModel** - Items de una venta
- **NumeradoModel** - Productos numerados/serializados
- **CondicionVentaModel** - Condiciones de pago
- **RutasModel** - Rutas de venta

## 5. Sistema de Rutas

La navegación usa `Navigator 1.0` con `onGenerateRoute`:

```
AppRouter.generateRoute()
    ├── /login          → LoginPage
    ├── /home           → HomePage
    ├── /rutas          → RutasPage
    ├── /productos      → ProductosPage
    ├── /clientes       → ClientesPage
    ├── /nuevaVenta     → VentaEncabezadoEdicionPage
    ├── /modificarVenta → VentaEncabezadoEdicionPage
    ├── /ventaDetalle   → ListadoDetalleDeUnaVentaPage
    └── /config         → ConfiguracionPage
```

## 6. Gestión de Estado

### 6.1 Provider Pattern
- Uso de `ChangeNotifierProvider` para servicios con estado reactivo
- `ConnectivityService` notifica cambios de conexión

### 6.2 BLoC Pattern
- Streams de RxDart para validación reactiva
- `LoginBloc` usa `BehaviorSubject` para campos de formulario

### 6.3 Service Locator
- `GetIt` para inyección de dependencias
- `locator<CondicionVentaBloc>()` para obtener instancias

## 7. Persistencia de Datos

### 7.1 SharedPreferences
- Preferencias de usuario (URL del servidor, vendedor actual)
- Configuración de la app

### 7.2 FlutterSecureStorage
- Tokens JWT (access_token, refresh_token)
- Credenciales del usuario

### 7.3 SQLite (sqflite)
- **No visible en el código actual** - احتمالاً para logs o caché

## 8. Sistema de Logging

```
lib/src/log/
├── log_util.dart         # Utilidades de logging
├── log_model.dart       # Modelo de log
├── db_log_provider.dart # Proveedor de logs en BD
└── console_log_page.dart # Vista de logs en consola
```

## 9. Background Service

La app usa `flutter_background_service` para:

- Tracking GPS cada 5 minutos
- Envío de ubicación al servidor
- Funciona en Android e iOS

## 10. Seguridad

- Tokens almacenados en `FlutterSecureStorage`
- Renovación automática de JWT (interceptores Dio)
- Validación de token en `AuthGate`

## 11. Supuestos y Observaciones

1. **Sin Redux/MobX** - El proyecto usa Provider + BLoC
2. **Navigator 1.0** - No usa Navigator 2.0 o GoRouter
3. **API REST** - No usa GraphQL
4. **Monolítico** - No tiene módulos/paquetes separados
5. **Sin Riverpod** - Usa Provider clásico
6. **Geolocalización activa** - Envía ubicación cada 5 minutos

## 12. Diagrama de Flujo de Inicio

```
main()
    ↓
PreferenciasUsuario.initPrefs()
    ↓
setupLocator() [GetIt]
    ↓
MultiProvider (Connectivity, Bloc, etc.)
    ↓
MyApp (MaterialApp)
    ↓
AuthGate._bootstrap()
    ├─ Validar permisos GPS
    ├─ Verificar JWT token
    ├─ Si válido → HomePage
    └─ Si inválido → LoginPage
```
