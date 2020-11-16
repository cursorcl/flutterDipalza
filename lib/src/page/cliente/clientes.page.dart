import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:flutter/material.dart';

class ClientesPage extends StatelessWidget {
  const ClientesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: Container(
          child: Center(
            child: Text(
              'Clientes',
              style: TextStyle(color: Colors.white),
            ),
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
          _creaListaClientes(context),
        ],
      )
    );
  }

  Widget _creaListaClientes(BuildContext context) {
    return RefreshIndicator(
        onRefresh: cargarNuevos,
        child: ListView(
          children: _clienteItems(context),
        ));
  }

  Future<Null> cargarNuevos() async {
    print('Carga datos Nuevos');
  }

  List<Widget> _clienteItems(BuildContext context) {
    final List<Widget> _listItem = [];

    for (var i = 0; i < 10; i++) {
      _listItem
      ..add(Card(
        child: ListTile(
          leading: CircleAvatar(radius: 25, child: Icon(Icons.account_box), backgroundColor: colorRojoBase(), foregroundColor: Colors.white,),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Juan Pérez Guzmán', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('999.999.999-9'),
              SizedBox(height: 5.0,)
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Marinero Fuentealba 614 Quilpué'),
              Text('+56996568959 - 322821789')
            ],
          ),
          trailing: IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: (){}),

          ),
        ),
      );

    }
    
    return _listItem;
  }
}
