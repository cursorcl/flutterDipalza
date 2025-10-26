// src/services/connectivity_service.dart

import 'dart:async';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

// Usamos el mismo Enum que definimos para la pantalla de Login
enum ServerStatus { online, offline, noInternet, connecting }

class ConnectivityService with ChangeNotifier {
  ServerStatus _status = ServerStatus.connecting;
  Timer? _timer;

  // Getter público para que los widgets puedan leer el estado actual
  ServerStatus get status => _status;

  // Método de inicialización para arrancar el monitoreo
  void initialize() {
    // Revisa el estado inmediatamente al iniciar
    _checkStatus();

    // Y luego establece un timer para que revise periódicamente
    _timer = Timer.periodic(const Duration(seconds: 15), (_) async => _checkStatus());
  }

  Future<void> _checkStatus() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    ServerStatus newStatus;

    if (connectivityResult.contains(ConnectivityResult.none)) {
      newStatus = ServerStatus.noInternet;
    } else {
      // Si hay internet, revisamos si el servidor responde
      final isServerOnline = await _isServerReachable();
      newStatus = isServerOnline ? ServerStatus.online : ServerStatus.offline;
    }

    // Solo notificar si el estado realmente ha cambiado
    // Esto evita reconstrucciones innecesarias de la UI
    if (newStatus != _status) {
      _status = newStatus;
      notifyListeners(); // ¡Esta es la magia! Notifica a todos los que escuchan.
    }
  }

  Future<bool> _isServerReachable() async {
    // Usa la misma URL de health-check de tu provider
    // Es buena idea tener estas URLs en un archivo de configuración central
    final prefs = PreferenciasUsuario();

    Uri url = Uri.http(prefs.urlServicio,"/ping");
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      // Cualquier excepción significa que el servidor no es accesible
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}