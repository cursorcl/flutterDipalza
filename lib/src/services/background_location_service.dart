import 'package:flutter_background_service/flutter_background_service.dart';

/// Nombre del mensaje que el isolate del servicio de ubicación usa para
/// avisarle a la UI (isolate principal) que la sesión expiró. El ApiClient
/// del servicio vive en un isolate distinto al de la UI, por lo que su
/// stream `onSessionExpired` no llega solo — hay que reenviarlo a través
/// del canal de mensajería de flutter_background_service.
const String kMensajeSesionExpirada = 'sessionExpired';

/// Detiene el servicio de ubicación en segundo plano (logout / sesión
/// expirada). Si el usuario vuelve a iniciar sesión sin reiniciar la app,
/// el servicio permanece detenido hasta el próximo arranque en frío.
Future<void> detenerServicioUbicacion() async {
  final service = FlutterBackgroundService();
  final running = await service.isRunning();
  if (running) {
    service.invoke('stopService');
  }
}
