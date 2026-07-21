import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Solicita el permiso de ubicación en segundo plano ("Permitir siempre"),
/// mostrando primero una explicación (sube la tasa de aceptación) y pidiendo
/// los permisos en el orden que exige el sistema operativo: primero
/// foreground, luego background. Si el usuario ya lo rechazó de forma
/// permanente, ofrece abrir Ajustes en vez de insistir con un diálogo del
/// sistema que ya no volverá a aparecer.
Future<void> solicitarPermisoUbicacionSiempre(BuildContext context) async {
  if (await Permission.locationAlways.isGranted) return;

  if (!context.mounted) return;
  final continuar = await _mostrarRationale(context);
  if (continuar != true) return;

  final foreground = await Permission.location.request();
  if (!foreground.isGranted) {
    if (foreground.isPermanentlyDenied && context.mounted) {
      await _mostrarDialogoAjustes(context);
    }
    return;
  }

  final background = await Permission.locationAlways.request();
  if (!background.isGranted && context.mounted) {
    await _mostrarDialogoAjustes(context);
  }
}

Future<bool?> _mostrarRationale(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Ubicación en segundo plano'),
      content: const Text(
        'Dipalza necesita tu ubicación todo el tiempo para que el equipo '
        'de logística pueda seguir tu recorrido y coordinar rutas, incluso '
        'con la app cerrada. En la siguiente pantalla, elige "Permitir '
        'todo el tiempo".',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Continuar'),
        ),
      ],
    ),
  );
}

Future<void> _mostrarDialogoAjustes(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Permiso de ubicación pendiente'),
      content: const Text(
        'Sin este permiso no podremos reportar tu posición al equipo de '
        'logística. Puedes activarlo manualmente en Ajustes > Ubicación > '
        'Permitir todo el tiempo.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            openAppSettings();
          },
          child: const Text('Abrir Ajustes'),
        ),
      ],
    ),
  );
}
