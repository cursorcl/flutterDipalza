import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/provider/cliente_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({Key key}) : super(key: key);

  @override
  _ClientesPageState createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  TextEditingController controller = new TextEditingController();
  List<ClientesModel> _searchResult = [];
  List<ClientesModel> _listaClientes = [];
  bool _verBuscar = false;

  Future<Null> getListaClientes() async {
    final prefs = new PreferenciasUsuario();
    _listaClientes = await ClientesProvider.clientesProvider
        .obtenerListaClientes(prefs.code, prefs.ruta, context);
    setState(() {});
  }

  Future<void> getListaClientesRefrescar() async {
    getListaClientes();
    onSearchTextChanged(controller.text);
  }

  @override
  void initState() {
    super.initState();
    getListaClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushNamed(context, 'home')),
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
            onPressed: () {
              setState(() {
                _verBuscar = true;
              });
            },
          ),
        ],
      ),
      // body: Stack(
      //   children: <Widget>[
      //     FondoWidget(),
      //     _creaListaClientes(context),
      //   ],
      // ),
      body: Column(
        children: <Widget>[
          _verBuscar ? _creaInputBuscar(context) : Container(),
          Expanded(
              child: _searchResult.length != 0 || controller.text.isNotEmpty
                  ? _creaListaClientes(context, _searchResult)
                  : _creaListaClientes(context, _listaClientes)),
        ],
      ),
    );
  }

  Widget _creaInputBuscar(BuildContext context) {
    return AnimatedOpacity(
      opacity: _verBuscar ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: Container(
        color: colorRojoBase(),
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Card(
            child: new ListTile(
              leading: new Icon(Icons.search),
              title: new TextField(
                controller: controller,
                decoration: new InputDecoration(
                    hintText: 'Buscar', border: InputBorder.none),
                onChanged: onSearchTextChanged,
              ),
              trailing: new IconButton(
                icon: new Icon(Icons.cancel),
                onPressed: () {
                  controller.clear();
                  onSearchTextChanged('');
                  setState(() {
                    _verBuscar = false;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _listaClientes.forEach((clientes) {
      if (clientes.razon.contains(text)) _searchResult.add(clientes);
    });

    setState(() {});
  }

  Widget _creaListaClientes(
      BuildContext context, List<ClientesModel> listaCliente) {
    
    if (listaCliente.length == 0) {
      return Center(
        child: Text('No existen Clientes para la conbinación Vendedor / Ruta.'),
      );
    }

    return RefreshIndicator(
      onRefresh: getListaClientesRefrescar,
      child: ListView.builder(
        itemCount: listaCliente.length,
        itemBuilder: (context, i) {
          return _creaCard(listaCliente[i]);
        },
      ),
    );
  }

  _creaCard(ClientesModel cliente) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          child: Icon(Icons.account_box),
          backgroundColor: colorRojoBase(),
          foregroundColor: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(cliente.razon, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(getFormatRut(cliente.rut)),
            SizedBox(
              height: 5.0,
            )
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[Text(cliente.direccion), Text(cliente.telefono)],
        ),
        trailing:
            IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: () {Navigator.pushNamed(context, 'venta', arguments: cliente);}),
      ),
    );
  }

  // List<Widget> _clienteItems(BuildContext context) {
  //   final List<Widget> _listItem = [];

  //   for (var i = 0; i < 10; i++) {
  //     _listItem
  //       ..add(
  //         Card(
  //           child: ListTile(
  //             leading: CircleAvatar(
  //               radius: 25,
  //               child: Icon(Icons.account_box),
  //               backgroundColor: colorRojoBase(),
  //               foregroundColor: Colors.white,
  //             ),
  //             title: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 Text('Juan Pérez Guzmán',
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 Text('999.999.999-9'),
  //                 SizedBox(
  //                   height: 5.0,
  //                 )
  //               ],
  //             ),
  //             subtitle: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 Text('Marinero Fuentealba 614 Quilpué'),
  //                 Text('+56996568959 - 322821789')
  //               ],
  //             ),
  //             trailing: IconButton(
  //                 icon: Icon(Icons.arrow_forward_ios), onPressed: () {}),
  //           ),
  //         ),
  //       );
  //   }

  //   return _listItem;
  // }
}
