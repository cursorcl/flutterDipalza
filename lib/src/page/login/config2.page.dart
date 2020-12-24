import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:flutter/material.dart';

class Configuracion2Page extends StatefulWidget {
  const Configuracion2Page({Key key}) : super(key: key);

  @override
  _Configuracion2PageState createState() => _Configuracion2PageState();
}

class _Configuracion2PageState extends State<Configuracion2Page> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[FondoWidget(), logo(context)],
      ),
    );
  }

  Widget logo(BuildContext context) {
    return Center(
      child: Image(
        image: AssetImage('assets/image/logo_dipalza_transparente.png'),
        width: 200.0,
        fit: BoxFit.cover,
      ),
    );
  }
}
