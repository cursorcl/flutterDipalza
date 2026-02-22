import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Para tus permisos
import 'package:jwt_decoder/jwt_decoder.dart'; // Asegúrate de tener esta dependencia

import '../../services/api_client.dart';
import '../../share/app.navigator.dart';
import '../../share/app_routes.dart';
import '../../share/prefs_usuario.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  @override
  void initState() {
    super.initState();
    // Ejecutamos la validación apenas arranca el widget
    // Usamos addPostFrameCallback para asegurar que el contexto esté listo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    // 1. (Opcional) Pequeña pausa para que se vea tu logo y no sea un parpadeo
    await Future.delayed(const Duration(seconds: 2));

    // 2. Validar Permisos (Movemos tu lógica aquí para no congelar el main)
    await _validaPermisos();

    // 3. Verificar Sesión
    final prefs = PreferenciasUsuario();
    final refreshToken = prefs.refreshToken;

    print("RefreshToken recuperado: '$refreshToken'");

    // Asumimos inválido por defecto
    bool isSessionValid = false;

    if (refreshToken.isNotEmpty) {
      try {
        // Si el token es basura, JwtDecoder lanzará excepción y caeremos al catch.
        bool isExpired = JwtDecoder.isExpired(refreshToken);

        if (!isExpired) {
          final apiClient = ApiClient();
          final renovado = await apiClient.renovarToken();
          if (renovado) {
            isSessionValid = true;
          } else {
            isSessionValid = false;
          }
        } else {
          print("El token tiene formato válido pero ha expirado.");
        }
      } catch (e) {
        // AQUÍ CAPTURAMOS TU ERROR
        print("Error al decodificar token (formato inválido): $e");
        isSessionValid = false;
      }
    }

    // 4. Navegación
    if (!mounted) return; // Seguridad por si el usuario cerró la app

    if (isSessionValid) {
      // Usamos pushReplacementNamed para que no pueda volver atrás al Splash
      AppNavigator.pushReplacementNamed(AppRoutes.home);
    } else {
      await prefs.borrarCredenciales();
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  Future<void> _validaPermisos() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Intento secundario
        await Geolocator.requestPermission();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Diseño de tu Splash Screen
    return Scaffold(
      backgroundColor: Colors.white, // O el color de tu marca
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pega aquí tu Logo si tienes uno:
            // Image.asset('assets/img/logo_dipalza.png', width: 150),
            const Icon(Icons.shield_moon, size: 80, color: Colors.blue), // Placeholder
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              "Iniciando sistema...",
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}