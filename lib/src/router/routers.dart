import 'package:dipalza_movil/src/log/console_log.page.dart';
import 'package:dipalza_movil/src/page/cliente/clientes.page.dart';
import 'package:dipalza_movil/src/page/config/preferences.page.dart';
import 'package:dipalza_movil/src/page/login/login.page.dart';
import 'package:dipalza_movil/src/page/producto/productos.page.dart';
import 'package:dipalza_movil/src/page/ventas/listado.de.ventas.page.dart';
import 'package:dipalza_movil/src/page/ventas/venta.encabezado.edicion.page.dart';
import 'package:flutter/material.dart';

import '../page/home/home.page.dart';
import '../page/ventas/listado.detalle.de.una.venta.dart';

Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    // 'estadistica': (BuildContext context) => EstadisticaPage(),

    '/': (BuildContext context) => HomePage(),
    'login': (BuildContext context) => LoginPage(),
    'config': (BuildContext context) => ConfiguracionPage(),

    'clientes': (BuildContext context) => ClientesPage(),

    'home': (BuildContext context) => HomePage(),
    'productos': (BuildContext context) => ProductosPage(),
    'listadoDeVentas': (BuildContext context) => ListadeDeVentasPage(),
    'consoleLog': (BuildContext context) => ConsoleLogPage(),
    'nuevaVenta': (BuildContext context) => VentaEncabezadoEdicionPage(),
  };

}