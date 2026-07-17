import 'dart:async';

import 'package:dipalza_movil/src/bloc/login_bloc.dart';
import 'package:dipalza_movil/src/page/login/auth_gate.dart';
import 'package:dipalza_movil/src/services/api_client.dart';
import 'package:dipalza_movil/src/services/connectivity_service.dart';
import 'package:dipalza_movil/src/services/locator.dart';
import 'package:dipalza_movil/src/share/app.navigator.dart';
import 'package:dipalza_movil/src/share/app_router.dart';
import 'package:dipalza_movil/src/share/app_routes.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
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
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return true; // sale de onStart limpiamente
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        _ultimaPosicionConocida = position;
        _enviarAlServidor(apiClient, position);
      },
      onError: (e) => debugPrint('[BG] Error en stream GPS: $e'),
    );
  } else {
    // Android: timer cada 5 minutos
    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 500,
      intervalDuration: const Duration(minutes: 1),
    );

    Timer.periodic(const Duration(minutes: 1), (timer) async {
      // ✅ Guard antes de pedir posición
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[BG] GPS desactivado, skip envío');
        return; // espera al próximo tick
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('[BG] Permiso de ubicación denegado, skip envío');
        return;
      }

      try {
        _ultimaPosicionConocida = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
        await _enviarAlServidor(apiClient, _ultimaPosicionConocida);
      } catch (e) {
        debugPrint('[BG] Error obteniendo posición: $e');
      }
    });
  }

  return true;
}

Future<void> _enviarAlServidor(ApiClient _apiClient, Position position) async {
  try {
    final prefs = PreferenciasUsuario();
    await prefs.initPrefs();
    if (prefs.access_token.isEmpty || prefs.vendedor.isEmpty) return;
    await _apiClient.dio.post('/api/posicion', data: {
      'vendedorId': prefs.vendedor,
      'latitud': position.latitude,
      'longitud': position.longitude,
      'fechaHora': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    debugPrint("Error en envío periódico: $e");
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // ✅ Crear el canal ANTES de configurar el servicio (Android 8+)
  final FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();
  await flnp
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
    'dipalza_location_channel',        // mismo ID que en AndroidConfiguration
    'Dipalza Ubicación',
    description: 'Monitoreo de ubicación para logística',
    importance: Importance.low,        // low evita sonido en notif persistente
  ));

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'dipalza_location_channel',
      initialNotificationTitle: 'Dipalza en ejecución',
      initialNotificationContent: 'Monitoreando ubicación para logística',
      foregroundServiceNotificationId: 888, // ✅ ID fijo requerido en v5+
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
    prefs.urlServicio = 'ventas.dynalias.net:8080'; // 'cursorcl.dynalias.com:8099';
  }

  // ✅ Solicitar permisos ANTES de inicializar el servicio
  await Permission.notification.request();
  await Permission.location.request();
  await Permission.locationAlways.request();

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

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _sessionSub;

  @override
  void initState() {
    super.initState();
    _sessionSub = ApiClient().onSessionExpired.listen((_) {
      if (mounted) {
        _handleSessionExpired();
      }
    });
  }

  @override
  void dispose() {
    _sessionSub.cancel();
    super.dispose();
  }

  void _handleSessionExpired() async {
    final prefs = PreferenciasUsuario();
    await prefs.borrarCredenciales();
    AppNavigator.goToLogin();
  }

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'CL')],
      locale: const Locale('es', 'CL'),
    );
  }
}
