import 'package:dipalza_movil/src/model/configuracion_model.dart';
import 'package:dipalza_movil/src/page/home/home.page.dart';
import 'package:dipalza_movil/src/provider/login_provider.dart';
import 'package:dipalza_movil/src/provider/parametros_provider.dart';
import 'package:dipalza_movil/src/router/routers.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    final prefs = new PreferenciasUsuario();
  await prefs.initPrefs();
  prefs.token = '';
  if (prefs.urlServicio == '') {
    prefs.urlServicio = 'cursorcl.dynalias.com:8099';
  }

  List<ConfiguracionModel> lista = await ParametrosProvider.parametrosProvider.obtenerConfiguraciones();
  lista.forEach((element) {
    if(element.clave == 'reporte'){
       prefs.reporte = int.parse(element.valor);
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LoginProvider(
          child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Diplaza App.',
        initialRoute: 'login',
        routes: getApplicationRoutes(),
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(builder: (BuildContext context) => HomePage());
        },
        // localizationsDelegates: [
        //     GlobalMaterialLocalizations.delegate,
        //     GlobalWidgetsLocalizations.delegate,
        //   ],
        // supportedLocales: [
        //       const Locale('en', 'US'),
        //       const Locale('es', 'ES'),
        //     ],
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
    );
  }
}


