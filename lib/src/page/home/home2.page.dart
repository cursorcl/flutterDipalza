import 'dart:io';
import 'dart:ui';

import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/cliente.widget.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:flutter/material.dart';

class Homev2Page extends StatelessWidget {
  const Homev2Page({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        FondoWidget(),
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              title(),
              buttonsRounded(context),
            ],
          ),
        ),
      ]),
      // bottomNavigationBar: bottomNavigationBar(context),
      floatingActionButton: creaBtnNuevaVenta(context),
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

  // Widget bottomNavigationBar(BuildContext context) {
  //   return new Theme(
  //       data: Theme.of(context).copyWith(
  //         canvasColor: Color.fromRGBO(0, 0, 14, 1.0),
  //         primaryColor: Colors.blueAccent,
  //         textTheme: Theme.of(context).textTheme.copyWith(
  //             caption: TextStyle(color: Color.fromRGBO(116, 117, 152, 1.0))),
  //       ),
  //       child: buttomNavigationBar());
  // }

  // Widget buttomNavigationBar() {
  //   return BottomNavigationBar(items: <BottomNavigationBarItem>[
  //     BottomNavigationBarItem(
  //         icon: Icon(Icons.calendar_today), title: Container()),
  //     BottomNavigationBarItem(
  //         icon: Icon(Icons.pie_chart_outlined), title: Container()),
  //     BottomNavigationBarItem(
  //         icon: Icon(Icons.supervised_user_circle), title: Container()),
  //   ]);
  // }

  Widget buttonsRounded(BuildContext context) {
    return Table(
      children: <TableRow>[
        TableRow(children: [
          makeRoundedButton(
              Colors.green, Icons.shopping_cart, "Ventas", context, 'listaVentas'),
           makeRoundedButton(
              Colors.yellow, Icons.receipt, "Productos", context, 'productos'),          
        ]),
        TableRow(children: [
         makeRoundedButton(Colors.blue, Icons.person_outline, "Clientes",
              context, 'clientes'),
          makeRoundedButton(
              Colors.red, Icons.history, "Historia", context, 'estadistica'),
        ]),
        TableRow(children: [
          makeRoundedButton(Colors.grey, Icons.phonelink_setup, "Configuración",
              context, 'config'),
          makeRoundedButtonExit(
              Colors.grey, Icons.exit_to_app, "Salir", context),
        ]),
      ],
    );
  }

  Widget makeRoundedButton(Color color, IconData icon, String text,
      BuildContext context, String route) {
    return ClipRect(
      // child: GestureDetector(
        child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 170.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.2),
                borderRadius: BorderRadius.circular(20.0)),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    height: 1.0,
                  ),
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: color,
                    child: Icon(icon, color: Colors.white, size: 45.0),
                  ),
                  Text(text, style: TextStyle(color: Colors.white)),
                  SizedBox(
                    height: 5.0,
                  )
                ]),
          ),
        ),
      ),
    );
  }

  Widget makeRoundedButtonExit(Color color, IconData icon, String text,
      BuildContext context) {
    return ClipRect(
      // child: GestureDetector(
        child: InkWell(
        onTap: () => validaCierre(context),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 170.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.2),
                borderRadius: BorderRadius.circular(20.0)),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    height: 1.0,
                  ),
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: color,
                    child: Icon(icon, color: Colors.white, size: 45.0),
                  ),
                  Text(text, style: TextStyle(color: Colors.white)),
                  SizedBox(
                    height: 5.0,
                  )
                ]),
          ),
        ),
      ),
    );
  }

  Padding creaBtnNuevaVenta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, bottom: 0.0),
      child: ClientesWidget(),
    );
  }

  Future<bool> validaCierre(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    // barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Center(
          child: Text(
            'Salir',
            style: TextStyle(color: Theme.of(context).primaryColor),
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
                      width: 100.0,
                      child: RaisedButton(
                        child: Container(
                          child: Text('Cancelar'),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        elevation: 0.0,
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Container(
                      width: 100.0,
                      child: RaisedButton(
                        child: Container(
                          child: Text('Salir'),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        elevation: 0.0,
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: ()=> exit(0),                        
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

}