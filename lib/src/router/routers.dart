import 'package:dipalza_movil/src/log/console_log.page.dart';
import 'package:dipalza_movil/src/page/cliente/clientes.page.dart';
import 'package:dipalza_movil/src/page/config/preferences.page.dart';
import 'package:dipalza_movil/src/page/login/login.page.dart';
import 'package:dipalza_movil/src/page/producto/productos.page.dart';
import 'package:dipalza_movil/src/page/ventas/listaventas.page.dart';
import 'package:dipalza_movil/src/page/ventas/ventas.page.dart';
import 'package:flutter/material.dart';

import '../page/home/home.page.dart';

Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    'login': (BuildContext context) => LoginPage(),
    'config': (BuildContext context) => ConfiguracionPage(),
    '/': (BuildContext context) => HomePage(),
    'clientes': (BuildContext context) => ClientesPage(),
    // 'estadistica': (BuildContext context) => EstadisticaPage(),
    'home': (BuildContext context) => HomePage(),
    'productos': (BuildContext context) => ProductosPage(),
    'venta': (BuildContext context) => VentasPage(),
    'listaVentas': (BuildContext context) => ListaVentasPage(),
    'consoleLog': (BuildContext context) => ConsoleLogPage(),
  };

}