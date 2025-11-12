import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:dipalza_movil/src/model/position_model.dart';
import 'package:dipalza_movil/src/provider/parametros_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/widget/cliente.select.widget.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dipalza_movil/src/page/home/ActionTile.dart';

import '../ventas/listaventas.page.dart';

class HomeAction {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const HomeAction(this.icon, this.color, this.label, this.onTap);
}

class Homev2Page extends StatelessWidget {
  const Homev2Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final items = <HomeAction>[
      HomeAction(Icons.shopping_cart, Colors.green, 'Ventas',
          () => _go(context, 'listaVentas')),
      HomeAction(Icons.receipt_long, Colors.yellow, 'Productos',
          () => _go(context, 'productos')),
      HomeAction(Icons.person_outline, Colors.blue, 'Clientes',
          () => _go(context, 'clientes')),
      HomeAction(Icons.settings, Colors.grey, 'Configuración',
          () => _go(context, 'config')),
      HomeAction(
          Icons.logout, Colors.red, 'Salir', () => validaCierre(context)),
    ];

    _notificaUbicacion();

    return Scaffold(
      body: Stack(children: [
        const Positioned.fill(child: FondoWidget()),
        // Scrim para mejorar contraste de textos e íconos
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
        SafeArea(
          child: Column(children: <Widget>[
            title(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: GridView.builder(
                  itemCount: items.length, // su lista de acciones
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, i) => ActionTile(
                    icon: items[i].icon,
                    color: items[i].color,
                    label: items[i].label,
                    onTap: items[i].onTap,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
      floatingActionButton: makeFloatingPoint(context),
    );
  }

  Widget title() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image(
              image: AssetImage('assets/image/logo_dipalza_transparente.png'),
              width: 200.0,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  Padding makeFloatingPoint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, bottom: 0.0),
      //child: ClientesSelectWidget(),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListaVentasPage()),
          );
        },
        child: const Icon(Icons.list), // Puedes cambiar el ícono
      ),
    );
  }

  Future<bool?> validaCierre(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Center(
            child: Text(
              'Salir',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(child: Text('¿Deseas Salir de la aplicación Móvil?')),
                Container(
                  padding: EdgeInsets.only(top: 30.0, left: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: 110.0,
                        child: ElevatedButton(
                          child: Text('Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            textStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Container(
                        width: 110.0,
                        child: ElevatedButton(
                          child: Container(
                            child: Text('Salir', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: Theme.of(context).primaryColor,
                            elevation: 0.0,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => {
                            _go(context, "login")
                          }
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _notificaUbicacion() {
    final prefs = new PreferenciasUsuario();

    Timer.periodic(Duration(milliseconds: prefs.reporte), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      PositionModel ubicacion = new PositionModel();
      ubicacion.latitude = position.latitude;
      ubicacion.longitude = position.longitude;
      ubicacion.velocidad = position.speed;
      ubicacion.fecha = DateTime.now();
      ubicacion.vendedor = prefs.vendedor;
      ParametrosProvider.parametrosProvider.registrarUbicacion(ubicacion);
    });
  }

  void _go(BuildContext context, String route) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, route);
  }
}
