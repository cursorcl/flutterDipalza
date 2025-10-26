// src/widget/connectivity_banner.widget.dart

import 'package:dipalza_movil/src/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // context.watch<T>() es la forma de "suscribirse" a los cambios de un Provider
    final connectivityService = context.watch<ConnectivityService>();

    // Si el estado es 'online', no mostramos nada.
    if (connectivityService.status == ServerStatus.online) {
      return const SizedBox.shrink(); // Un widget vacío y de tamaño cero
    }

    // Si hay un problema de conexión, mostramos el banner
    String message;
    Color color;
    IconData icon;

    switch (connectivityService.status) {
      case ServerStatus.noInternet:
        message = 'Sin conexión a Internet';
        color = Colors.grey.shade700;
        icon = Icons.wifi_off;
        break;
      case ServerStatus.offline:
        message = 'No se puede conectar con el servidor';
        color = Colors.red.shade700;
        icon = Icons.cloud_off_rounded;
        break;
      case ServerStatus.connecting:
        message = 'Conectando...';
        color = Colors.orange.shade800;
        icon = Icons.cloud_sync_rounded;
        break;
      default:
        message = 'Conectado';
        color = Colors.green;
        icon = Icons.cloud_done;
    }

    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}