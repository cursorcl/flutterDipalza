import 'dart:async';
import 'package:dipalza_movil/src/model/position_model.dart';
import 'package:dipalza_movil/src/provider/parametros_provider.dart';
import 'package:dipalza_movil/src/share/app_routes.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../model/venta_model.dart';
import '../../share/app.navigator.dart';
import '../cliente/clientes.page.dart';
import '../producto/productos.page.dart';
import '../rutas/rutas.page.dart';
import '../ventas/listado.de.ventas.page.dart';
import '../config/config.page.dart';
import '../ventas/listado.detalle.de.una.venta.dart';
import '../ventas/venta.encabezado.edicion.page.dart';
import '../ventas/venta.item.detalle.edicion.dart';

class Homev2Page extends StatefulWidget {  // Cambiar a StatefulWidget
  const Homev2Page({Key? key}) : super(key: key);

  @override
  State<Homev2Page> createState() => _Homev2PageState();
}

class _Homev2PageState extends State<Homev2Page> {
  final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    // Asegurarse de que el Navigator esté listo después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Aquí el Navigator ya está montado
      print('Navigator listo: ${homeNavigatorKey.currentState != null}');
    });
  }



  @override
  Widget build(BuildContext context) {
    _notificaUbicacion();

    return Scaffold(
      body: Stack(
        children: [
          // ---------------------------------------------------
          // FONDO
          // ---------------------------------------------------
          const Positioned.fill(child: FondoWidget()),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0x8BE4AF09)],
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                ),
              ),
            ),
          ),

          // ---------------------------------------------------
          // CONTENIDO PRINCIPAL (SAFEAREA)
          // ---------------------------------------------------
          SafeArea(
            child: Stack(
              children: [
                // ---------------------------------------------------
                // TITULO / LOGO EN LA PARTE SUPERIOR
                // ---------------------------------------------------
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: title(),
                ),

                // ---------------------------------------------------
                // NAVEGADOR INTERNO — SIEMPRE SE MONTA CORRECTAMENTE
                // ---------------------------------------------------
                Positioned.fill(
                  top: 120, // altura reservada para tu título
                  child: Navigator(
                    key: homeNavigatorKey,
                    onGenerateInitialRoutes: (navigator, initialRoute) {
                      return [
                        MaterialPageRoute(
                          settings: const RouteSettings(name: AppRoutes.listadoVentas),
                          builder: (_) => ListadeDeVentasPage(),
                        ),
                      ];
                    },
                    onGenerateRoute: (settings) {
                      late Widget page;

                      switch (settings.name) {
                        case AppRoutes.listadoVentas:
                          page = ListadeDeVentasPage();
                          break;

                        case AppRoutes.productos:
                          page = ProductosPage();
                          break;

                        case AppRoutes.productosSeleccion:
                          page = const ProductosPage(isForSelection: true);
                          break;

                        case AppRoutes.clientes:
                          page = ClientesPage();
                          break;

                        case AppRoutes.clientesSeleccion:
                          page = const ClientesPage(isForSelection: true);
                          break;

                        case AppRoutes.config:
                          page = ConfiguracionPage();
                          break;

                        case AppRoutes.rutas:
                          page = RutasPage();
                          break;

                        case AppRoutes.nuevaVenta:
                          final ventaEnEdicion = settings.arguments as VentaModel?;
                          page = VentaEncabezadoEdicionPage(ventaEnEdicion: ventaEnEdicion);
                          break;

                        case AppRoutes.ventaDetalle:
                          final args = settings.arguments as Map<String, dynamic>;
                          page = ListadoDetalleDeUnaVentaPage(
                            ventaModel: args['ventaModel'],
                            esEdicion: args['esEdicion'],
                          );
                          break;

                        case AppRoutes.ventaItemEdicion:
                          final args = settings.arguments as Map<String, dynamic>;
                          page = VentaEdicionItemDetalle(
                            actualVenta: args['actualVenta'],
                            actualVentaDetalle: args['actualVentaDetalle'],
                          );
                          break;

                        default:
                          page = ListadeDeVentasPage();
                          break;
                      }

                      return PageRouteBuilder(
                        opaque: false,
                        barrierColor: Colors.transparent,
                        pageBuilder: (_, __, ___) => page,
                        transitionDuration: const Duration(milliseconds: 0),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //   WIDGETS DEL HOME
  // ============================================================

  Widget title() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Image(
        image: const AssetImage('assets/image/logo_dipalza_transparente.png'),
        width: 200.0,
        fit: BoxFit.cover,
      ),
    );
  }

  // FAB que ahora navega por el navigator interno
  Padding makeFloatingPoint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: FloatingActionButton(
        onPressed: () {
          homeNavigatorKey.currentState!.pushNamed('listadoDeVentas');
        },
        child: const Icon(Icons.list),
      ),
    );
  }

  // ============================================================
  //   NAVEGACIÓN INTERNA
  // ============================================================

  void _go(BuildContext context, String route) {
    HapticFeedback.lightImpact();

    if (route == 'login') {
      // este sí debe usar el navigator global
      Navigator.of(context).pushReplacementNamed('login');
    } else {
      homeNavigatorKey.currentState!.pushNamed(route);
    }
  }

  // ============================================================
  //   LÓGICA DE UBICACIÓN
  // ============================================================

  void _notificaUbicacion() {
    final prefs = PreferenciasUsuario();

    Timer.periodic(Duration(milliseconds: prefs.reporte), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      PositionModel ubicacion = PositionModel();
      ubicacion.latitude = position.latitude;
      ubicacion.longitude = position.longitude;
      ubicacion.velocidad = position.speed;
      ubicacion.fecha = DateTime.now();
      ubicacion.vendedor = prefs.vendedor;

      ParametrosProvider.parametrosProvider.registrarUbicacion(ubicacion);
    });
  }

  Future<bool?> validaCierre(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
            child: Text(
              'Salir',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Center(child: Text('¿Deseas salir de la aplicación Móvil?')),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      width: 110,
                      child: ElevatedButton(
                        child: Text('Cancelar',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => AppNavigator.pop(),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: ElevatedButton(
                        child: Text('Salir',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _go(context, "login"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
