import 'dart:ui';

import 'package:dipalza_movil/src/utils/utils.dart';
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
          makeRoundedButton(Colors.blue, Icons.person_outline, "Clientes",
              context, 'clientes'),
        ]),
        TableRow(children: [
          makeRoundedButton(
              Colors.blue, Icons.receipt, "Productos", context, 'productos'),
          makeRoundedButton(
              Colors.red, Icons.history, "Historia", context, 'estadistica'),
        ]),
        TableRow(children: [
          makeRoundedButton(Colors.grey, Icons.phonelink_setup, "Configuración",
              context, 'config'),
          makeRoundedButton(
              Colors.blue, Icons.account_box, "Acerca de", context, 'aboutof'),
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

  Padding creaBtnNuevaVenta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, bottom: 0.0),
      child: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, 'venta'),
        backgroundColor: HexColor('#ff7043'),
        tooltip: 'Ingresar Venta',
        child: Icon(
          Icons.add,
          size: 35.0,
        ),
      ),
    );
  }
}