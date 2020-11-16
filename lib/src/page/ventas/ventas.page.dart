import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

class VentasPage extends StatelessWidget {
  const VentasPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: Container(
          child: Center(
            child: Text('Ventas', style: TextStyle(color: Colors.white),),
          ),
        ),
        actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Buscar',
          onPressed: () {},
        ),        
      ],
      ),
      body: Column(
        children: <Widget>[
          creaTituloPage(),
        ],
      ),
    );
  }

  Widget creaTituloPage() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: Text('VENTAS'),
        ),
      ),
    );
  }
}
