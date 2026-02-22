# Guía para Desarrolladores

## Introducción

Esta guía está diseñada para ayudar a nuevos desarrolladores a entender y trabajar con el proyecto Dipalza Móvil.

## Primeros Pasos

### 1. Configuración del Entorno

```bash
# Clonar el proyecto
git clone <repo-url>
cd flutterDipalza

# Instalar dependencias
flutter pub get

# Ejecutar en emulador/dispositivo
flutter run
```

### 2. Estructura de Carpetas

```
lib/
├── main.dart                    # Punto de entrada
└── src/
    ├── bloc/                    # Lógica de negocio con BLoC
    │   ├── login_bloc.dart
    │   ├── productos_bloc.dart
    │   ├── rutas_bloc.dart
    │   └── condicion_venta_bloc.dart
    │
    ├── log/                     # Sistema de logs
    │
    ├── model/                   # Modelos de datos
    │   ├── clientes_model.dart
    │   ├── producto_model.dart
    │   ├── venta_model.dart
    │   └── ...
    │
    ├── page/                    # Pantallas
    │   ├── login/
    │   ├── home/
    │   ├── ventas/
    │   ├── cliente/
    │   ├── producto/
    │   ├── config/
    │   └── rutas/
    │
    ├── provider/                # Providers (estado)
    │   ├── login_provider.dart
    │   ├── venta_provider.dart
    │   ├── cliente_provider.dart
    │   └── ...
    │
    ├── services/                # Servicios externos
    │   ├── api_client.dart      # Cliente HTTP (Dio)
    │   ├── connectivity_service.dart
    │   └── locator.dart         # GetIt
    │
    ├── share/                   # Utilidades compartidas
    │   ├── prefs_usuario.dart   # Preferencias del usuario
    │   ├── app_router.dart      # Navegación
    │   ├── app_routes.dart      # Constantes de rutas
    │   └── ...
    │
    ├── theme/                   # Temas
    │   ├── app_theme.dart
    │   ├── app_colors.dart
    │   └── app_color_scheme.dart
    │
    ├── utils/                   # Utilidades
    │   ├── jwt_util.dart
    │   ├── alert_util.dart
    │   └── utils.dart
    │
    ├── validacion/              # Validadores
    │   ├── rut_validator.dart
    │   └── productos_validacion.dart
    │
    └── widget/                  # Widgets reutilizables
```

## Conceptos Clave

### Providers vs BLoCs

- **Provider**: Para estado global simple (conectividad, preferencias)
- **BLoC**: Para lógica compleja con validación reactiva (login, formularios)

### ApiClient (Dio)

El cliente HTTP usa interceptores para:
- Agregar token JWT automáticamente
- Renovar token cuando expira (código 403)

```dart
// Ejemplo de uso
final apiClient = ApiClient();
final response = await apiClient.dio.get('/api/productos');
```

### PreferenciasUsuario

Singleton para acceso a preferencias:

```dart
final prefs = PreferenciasUsuario();
prefs.vendedor = 'V001';
prefs.urlServicio = 'mi-servidor.com:8099';
```

## Agregar una Nueva Pantalla

### 1. Crear la página

```dart
// lib/src/page/ejemplo/mi_pagina.dart
import 'package:flutter/material.dart';

class MiPagina extends StatelessWidget {
  const MiPagina({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi Página')),
      body: Center(child: Text('Contenido')),
    );
  }
}
```

### 2. Registrar la ruta

```dart
// lib/src/share/app_routes.dart
class AppRoutes {
  static const String miPagina = '/mi-pagina';
}
```

### 3. Configurar el router

```dart
// lib/src/share/app_router.dart (en generateRoute)
case AppRoutes.miPagina:
  return MaterialPageRoute(builder: (_) => const MiPagina());
```

### 4. Navegar

```dart
// Desde cualquier pantalla
Navigator.pushNamed(context, AppRoutes.miPagina);

// O con argumentos
Navigator.pushNamed(context, AppRoutes.miPagina, arguments: {'id': 1});
```

## Agregar un Nuevo Provider

```dart
// lib/src/provider/mi_provider.dart
import 'package:flutter/material.dart';

class MiProvider extends ChangeNotifier {
  String _dato = '';

  String get dato => _dato;

  void setDato(String valor) {
    _dato = valor;
    notifyListeners();
  }
}
```

### Registrar en main.dart

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MiProvider()),
  ],
  child: MyApp(),
)
```

## Agregar un Nuevo Modelo

```dart
// lib/src/model/mi_modelo.dart
class MiModelo {
  final String id;
  final String nombre;

  MiModelo({required this.id, required this.nombre});

  factory MiModelo.fromJson(Map<String, dynamic> json) => MiModelo(
    id: json["id"],
    nombre: json["nombre"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
}
```

## Llamadas a la API

### GET

```dart
final response = await _dio.get('/api/recurso');
final datos = response.data;
```

### POST

```dart
final response = await _dio.post('/api/recurso', data: {...});
```

### Con autenticación

El token se añade automáticamente por el interceptor.

## Validaciones

### RUT Chileno

```dart
import 'package:dipalza_movil/src/validacion/rut_validator.dart';

final esValido = RutValidator.validarRut('12345678-9');
```

## Estilos y Temas

### Usar tema

```dart
Theme.of(context).primaryColor
Theme.of(context).textTheme.headline6
```

### Colores disponibles

```dart
import 'package:dipalza_movil/src/theme/app_colors_widget.dart';

ColorsWidgets.primaryColor
ColorsWidgets.secondaryColor
```

## Testing

```bash
# Ejecutar tests
flutter test

# Tests unitarios
flutter test test/unit/

# Tests de widget
flutter test test/widget/
```

## Comandos Útiles

```bash
# Análisis de código
flutter analyze

# Build APK debug
flutter build apk --debug

# Build APK release
flutter build apk --release

# Build iOS
flutter build ios

# Limpiar y rebuild
flutter clean
flutter pub get
```

## Troubleshooting

### Error de conexión

1. Verificar que el servidor esté corriendo
2. Comprobar URL en preferencias
3. Verificar token JWT no haya expirado

### Error de ubicación

1. Verificar permisos de ubicación en el dispositivo
2. En iOS: verificar que Background Location esté habilitado

### Problemas con tokens

1. Limpiar datos de la app
2. Volver a iniciar sesión

## Dependencias Principales

| Paquete | Uso |
|---------|-----|
| provider | Gestión de estado |
| dio | Cliente HTTP |
| get_it | Inyección de dependencias |
| shared_preferences | Preferencias locales |
| flutter_secure_storage | Almacenamiento seguro |
| geolocator | GPS |
| sqflite | Base de datos local |
| rxdart | Streams reactivos |

## Notas Importantes

1. **URL por defecto**: `localhost:8099` (desarrollo)
2. **Permisos requeridos**: Ubicación (GPS)
3. **Target SDK**: Flutter 3.x
4. **Soporte offline**: Parcial (logueo y datos básicos)

## Contacto y Soporte

Para dudas sobre el proyecto, revisar la documentación en `docs/` o contactar al equipo de desarrollo.
