import 'dart:io' show Platform;

import 'package:dipalza_movil/src/share/app.navigator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/venta_model.dart';
import '../../share/app_routes.dart';
import '../cliente/clientes.page.dart';
import '../config/preferences.page.dart';
import '../producto/productos.page.dart';
import '../rutas/rutas.page.dart';
import '../ventas/listado.de.ventas.page.dart';
import '../ventas/listado.detalle.de.una.venta.dart';
import '../ventas/venta.encabezado.edicion.page.dart';
import '../ventas/venta.item.detalle.edicion.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String get _rootRoute {
    switch (_currentIndex) {
      case 0: return AppRoutes.listadoVentas;
      case 1: return AppRoutes.productos;
      case 2: return AppRoutes.clientes;
      case 3: return AppRoutes.config;
      default: return AppRoutes.listadoVentas;
    }
  }
  // Define aquí las páginas que correspondan a cada acción (excepto "Salir")
  late final List<Widget> _pages = <Widget>[
    const ListadeDeVentasPage(), // Ventas
    const ProductosPage(), // Productos
    const ClientesPage(), // Clientes
    const ConfiguracionPage(), // Configuración
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Contenido principal: por defecto ListaVentasPage
      body: Navigator(
        key: AppNavigator.navigatorKey,
        initialRoute: _rootRoute,
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
              page = VentaEncabezadoEdicionPage();
              break;
            case AppRoutes.modificarVenta:
              final args = settings.arguments as Map<String, dynamic>;
              final ventaEnEdicion = args['ventaEnEdicion'] as VentaModel?;
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
          //return MaterialPageRoute(builder: (_) => page);
          return PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => page,
            transitionDuration: const Duration(milliseconds: 0),
          );
        },
      ),

      /*
      bottomNavigationBar: SafeArea(
        child: Platform.isIOS
            ? CupertinoTabBar(
                currentIndex: _currentIndex,
                onTap: (index) async {
                  const int salirIndex = 4;
                  if (index == salirIndex) {
                    final salir = await _confirmarSalida(context);
                    if (salir == true && context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                    return;
                  }
                  setState(() => _currentIndex = index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.cart),
                    label: 'Ventas',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.cube_box),
                    label: 'Productos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.person),
                    label: 'Clientes',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.gear),
                    label: 'Configuración',
                  ),
                ],
              )
            : NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) async {
                  setState(() => _currentIndex = index);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.shopping_cart_outlined),
                    selectedIcon: Icon(Icons.shopping_cart),
                    label: 'Ventas',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: 'Productos',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Clientes',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Configuración',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.logout),
                    label: 'Salir',
                  ),
                ],
              ),
      ),
       */

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          AppNavigator.navigatorKey.currentState!.pushReplacementNamed(_rootRoute);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Ventas'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Productos'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Clientes'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }

  Future<bool?> _confirmarSalida(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar salida'),
        content: const Text('¿Desea cerrar la sesión y salir de la aplicación?'),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop( false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => AppNavigator.pop( true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
