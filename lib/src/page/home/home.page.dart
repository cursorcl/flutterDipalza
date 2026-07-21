// ignore_for_file: unused_import

import 'package:dipalza_movil/src/page/login/login.page.dart';
import 'package:dipalza_movil/src/page/ventas/listado.ultima.venta.page.dart';
import 'package:dipalza_movil/src/services/location_permission_service.dart';
import 'package:dipalza_movil/src/share/app.navigator.dart';
import 'package:flutter/material.dart';

import '../../model/venta_model.dart';
import '../../share/app_scaffold_key.dart';
import '../cliente/clientes.page.dart';
import '../config/preferences.page.dart';
import '../producto/productos.page.dart';
import '../rutas/rutas.page.dart';
import '../ventas/listado.de.ventas.page.dart';
import '../ventas/listado.detalle.de.una.venta.dart';
import '../ventas/resumen.de.ventas.page.dart';
import '../ventas/ultimas.ventas.cliente.page.dart';
import '../ventas/venta.encabezado.edicion.page.dart';
import '../ventas/venta.item.detalle.edicion.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const ListadeDeVentasPage(),
    const ResumenDeVentasPage(),
    const UltimasVentasClientePage(),
    const ProductosPage(),
    const ClientesPage(),
    const ConfiguracionPage(showMenuIcon: true),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) solicitarPermisoUbicacionSiempre(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          final salir = await _confirmarSalida(context);
          if (salir ?? false) {
            if (context.mounted) Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          key: AppScaffoldKey.homeKey,
          drawer: Drawer(
            child: Column(
              children: [
                const UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.red), // Tu color base
                  accountName: Text('Usuario Dipalza'),
                  accountEmail: Text('vendedor@dipalza.cl'),
                  currentAccountPicture:
                      CircleAvatar(child: Icon(Icons.person)),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Ventas'),
                  selected: _currentIndex == 0,
                  onTap: () => _navegar(0),
                ),
                ListTile(
                  leading: const Icon(Icons.assessment),
                  title: const Text('Resumen de Venta'),
                  selected: _currentIndex == 1,
                  onTap: () => _navegar(1),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Últimas Ventas'),
                  selected: _currentIndex == 2,
                  onTap: () => _navegar(2),
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Productos'),
                  selected: _currentIndex == 3,
                  onTap: () => _navegar(3),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Clientes'),
                  selected: _currentIndex == 4,
                  onTap: () => _navegar(4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configuración'),
                  selected: _currentIndex == 5,
                  onTap: () => _navegar(5),
                ),
              ],
            ),
          ),
          body: _pages[_currentIndex],
        ));
  }

  void _navegar(int index) {
    setState(() => _currentIndex = index);
    Navigator.pop(context); // Cierra el drawer automáticamente
  }

  Future<bool?> _confirmarSalida(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar salida'),
        content:
            const Text('¿Desea cerrar la sesión y salir de la aplicación?'),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => AppNavigator.pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
