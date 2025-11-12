import 'package:dipalza_movil/src/model/configuracion_model.dart';
import 'package:dipalza_movil/src/page/home/home.page.dart';
import 'package:dipalza_movil/src/provider/login_provider.dart';
import 'package:dipalza_movil/src/provider/parametros_provider.dart';
import 'package:dipalza_movil/src/router/routers.dart';
import 'package:dipalza_movil/src/services/connectivity_service.dart';
import 'package:dipalza_movil/src/services/locator.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'src/bloc/condicion_venta_bloc.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_CL', null);
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new PreferenciasUsuario();
  await prefs.initPrefs();
  prefs.token = '';
  if (prefs.urlServicio == '') {
    prefs.urlServicio = 'localhost:8099'; // 'cursorcl.dynalias.com:8099';
  }

  List<ConfiguracionModel> lista =
      await ParametrosProvider.parametrosProvider.obtenerConfiguraciones();
  lista.forEach((element) {
    if (element.clave == 'reporte') {
      prefs.reporte = int.parse(element.valor);
    }
  });

  validaPermisos();
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        // Aquí creamos la instancia única del servicio.
        // El `..initialize()` asegura que el monitoreo comience tan pronto se crea.
        ChangeNotifierProvider(
          create: (_) => ConnectivityService()..initialize(),
        ),
        Provider<CondicionVentaBloc>(
          // Se crea con locator, para que quede registrado y asú usar GetIt
          create: (_) => locator<CondicionVentaBloc>(),
          dispose: (_, bloc) => bloc.dispose(), // Provider llamará a dispose por nosotros!
        ),
      ],
      child: MyApp(), // Tu widget principal
    ),
  );
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Crear tu ColorScheme personalizado
    final appColorScheme = AppTheme.createAppColors(
      brightness: Brightness.light,
    );

    return LoginProvider(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Diplaza App.',
          initialRoute: 'login',
          routes: getApplicationRoutes(),
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(
                builder: (BuildContext context) => HomePage());
          },
          // Usar tu tema personalizado
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
    ));
  }
}

validaPermisos() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission.toString() != LocationPermission.always.toString()) {
    permission = await Geolocator.requestPermission();
    if (permission.toString() != LocationPermission.always.toString()) {
      permission = await Geolocator.requestPermission();
    }
  }
}
