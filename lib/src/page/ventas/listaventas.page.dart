import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:flutter/material.dart';

class ListaVentasPage extends StatelessWidget {
  const ListaVentasPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: Container(
          child: Center(
            child: Text('Lista de Ventas', style: TextStyle(color: Colors.white),),
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
      body: Stack(
        children: <Widget>[
          FondoWidget(),
          _creaListaVentas(context)
        ],
      ),
      floatingActionButton: creaBtnNuevaVenta(context),
    );
  }

 Widget _creaListaVentas(BuildContext context) {
    return RefreshIndicator(
        onRefresh: cargarNuevos,
        child: ListView(
          children: _ventasItems(context),
        ));
  }

  Future<Null> cargarNuevos() async {
    print('Carga datos Nuevos');
  }

  List<Widget> _ventasItems(BuildContext context) {
    final List<Widget> _listItem = [];

    for (var i = 0; i < 10; i++) {
      _listItem
      ..add(Card(
        child: ListTile(
          leading: CircleAvatar(radius: 20, child: Icon(Icons.insert_chart), backgroundColor: HexColor('#455a64'), foregroundColor: Colors.white,),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Juan Pérez Guzmán'),
              SizedBox(height: 5.0,)
            ],
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('16 Productos'),
              SizedBox(width: 20.0,),
              Text('\$345.000.-')
            ],
          ),
          trailing: IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: (){}),

          ),
        ),
      );

    }
    
    return _listItem;
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
