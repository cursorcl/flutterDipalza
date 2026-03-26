import 'dart:async';

import 'package:dipalza_movil/src/bloc/login_bloc.dart';
import 'package:dipalza_movil/src/page/login/auth_gate.dart';
import 'package:dipalza_movil/src/services/api_client.dart';
import 'package:dipalza_movil/src/services/connectivity_service.dart';
import 'package:dipalza_movil/src/services/locator.dart';
import 'package:dipalza_movil/src/share/app.navigator.dart';
import 'package:dipalza_movil/src/share/app_router.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'src/bloc/condicion_venta_bloc.dart';

Timer? _timerPosicion;
late Position _ultimaPosicionConocida;


// 1. Función global para el servicio
@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance service) async {
  final prefs = PreferenciasUsuario();
  await prefs.initPrefs();
  final apiClient = ApiClient();

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    // iOS: stream de ubicación
    final locationSettings = AppleSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 500,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
      allowBackgroundLocationUpdates: true,
    );
    Geolocator.getPositionStream(
      locationSettings: locationSettings
    ).listen((Position position) {
      _ultimaPosicionConocida = position;
      if (_ultimaPosicionConocida != null) {
         _enviarAlServidor(apiClient, _ultimaPosicionConocida!);
      }
    });

  } else {
    // Android: timer cada 5 minutos
    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 500,
      intervalDuration: const Duration(minutes: 1),
    );

    Timer.periodic(const Duration(minutes: 1), (timer) async {
        _ultimaPosicionConocida = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings);
        if (_ultimaPosicionConocida != null) {
          await _enviarAlServidor(apiClient, _ultimaPosicionConocida!);
        }
    });
  }

  return true;
}

Future<void> _enviarAlServidor(ApiClient _apiClient, Position position) async {
  try {
    final prefs = PreferenciasUsuario();
    await prefs.initPrefs();
    await _apiClient.dio.post('/api/posicion', data: {
      'vendedorId': prefs.vendedor,
      'latitud': position.latitude,
      'longitud': position.longitude,
      'fechaHora': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    print("Error en envío periódico: $e");
  }
}
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Rastreo Dipalza',
      initialNotificationContent: 'Enviando ubicación cada 5 minutos',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onStart,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_CL', null);
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new PreferenciasUsuario();
  await prefs.initPrefs();
  if (prefs.urlServicio == '') {
    prefs.urlServicio = 'localhost:8099'; // 'cursorcl.dynalias.com:8099';
  }
  setupLocator();
  await initializeService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ConnectivityService()..initialize(),
        ),
        Provider<CondicionVentaBloc>(
          create: (_) => locator<CondicionVentaBloc>(),
          dispose: (_, bloc) => bloc.dispose(),
        ),
        Provider<LoginBloc>(
          create: (_) => LoginBloc(),
          dispose: (_, bloc) => bloc.dispose(),
        ),
      ],
      child: MyApp(), // Tu widget principal
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppTheme.createAppColors(
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diplaza App.',
      navigatorKey: AppNavigator.navigatorKey,
      onGenerateRoute: AppRouter.generateRoute,
      home: const AuthGate(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
    );
  }
}
