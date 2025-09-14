import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../cliente/clientes.page.dart';
import '../config/preferences.page.dart';
import '../producto/productos.page.dart';
import '../ventas/listaventas.page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 0 = Ventas (por defecto mostrar ListaVentasPage)
  int _currentIndex = 0;

  // Define aquí las páginas que correspondan a cada acción (excepto "Salir")
  late final List<Widget> _pages = <Widget>[
    const ListaVentasPage(), // Ventas
    const ProductosPage(), // Productos
    const ClientesPage(), // Clientes
    const ConfiguracionPage(), // Configuración
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Contenido principal: por defecto ListaVentasPage
      body: _pages[_currentIndex],

// Reemplaza tu bottomNavigationBar con esto:
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
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
