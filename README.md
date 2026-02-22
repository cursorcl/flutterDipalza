# Dipalza Móvil

Aplicación móvil Flutter desarrollada para Dipalza Ltda. que permite realizar ventas en línea a vendedores/as.

## Resumen del Proyecto

Aplicación de ventas móviles diseñada para que el equipo de ventas pueda gestionar pedidos, clientes y rutas desde dispositivos móviles. La app se conecta a un backend REST API y soporta trabajo offline con sincronización.

**Versión actual:** 1.0.0 (build 11)

## Características Principales

- Gestión de clientes y rutas de venta
- Creación y edición de ventas
- Seguimiento de ubicación del vendedor (GPS)
- Autenticación con JWT tokens
- Persistencia local de datos
- Validación de RUT chileno

## Tecnologías

| Categoría | Tecnología |
|-----------|------------|
| Framework | Flutter 3.x |
| Estado | Provider + BLoC |
| HTTP | Dio |
| Local Storage | SharedPreferences + SQLite |
| Auth | JWT |
| Location | Geolocator |

## Requisitos

- Flutter SDK >= 2.17.0 < 4.0.0
- Dart SDK >= 2.17.0 < 4.0.0

## Instalación

```bash
flutter pub get
flutter run
```

## Estructura del Proyecto

```
lib/
├── main.dart                 # Entry point
└── src/
    ├── bloc/                 # BLoCs (lógica de negocio)
    ├── log/                  # Sistema de logs
    ├── model/                # Modelos de datos
    ├── page/                 # Pantallas/Widgets de UI
    ├── provider/             # Providers (estado)
    ├── router/               # Configuración de rutas
    ├── services/             # Servicios externos
    ├── share/                # Utilidades compartidas
    ├── theme/                # Temas y estilos
    ├── utils/                # Utilidades
    ├── validacion/           # Validadores
    └── widget/               # Widgets reutilizables
```

## Configuración

La URL del servicio se configura en las preferencias del usuario. Por defecto usa `localhost:8099` para desarrollo.

## API Endpoints

La aplicación se conecta a `http://{url_servicio}/api/` con autenticación Bearer JWT.

## Notas

- El servidor por defecto es `dipalza.dynalias.net:8099`
- Usa geolocalización en background para tracking de vendedores
- Soporta dark mode (configurable)
