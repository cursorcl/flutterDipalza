import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/provider/cliente_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

class ClientesPopUpPage extends StatefulWidget {
  const ClientesPopUpPage({Key key}) : super(key: key);

  @override
  _ClientesPopUpPageState createState() => _ClientesPopUpPageState();
}

class _ClientesPopUpPageState extends State<ClientesPopUpPage> {
  TextEditingController controller = new TextEditingController();
  List<ClientesModel> _searchResult = [];
  List<ClientesModel> _listaClientes = [];

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
    final List<Widget> lista = [];

    lista.add(_creaInputBuscar(context));
    lista.addAll(_creaListaClientes(
        context,
        _searchResult.length != 0 || controller.text.isNotEmpty
            ? _searchResult
            : _listaClientes));
    // lista.add(SizedBox(height: 10.0,));

    return Column(
      children: lista,
    );
  }

  Widget _creaInputBuscar(BuildContext context) {
    return Container(
      child: new Padding(
        padding: EdgeInsets.all(8.0),
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
                setState(() {});
              },
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

  List<Widget> _creaListaClientes(
      BuildContext context, List<ClientesModel> listaCliente) {
    final List<Widget> _listItem = [];

    if (listaCliente.length == 0) {
      _listItem.add(Center(
        child: Text('No existen registros.'),
      ));

      return _listItem;
    }

    listaCliente.forEach((cliente) {
      _listItem.add(_creaCard(context, cliente));
    });
    setState(() {});
    return _listItem;
  }

  _creaCard(BuildContext context, ClientesModel cliente) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          child: Icon(Icons.account_box),
          backgroundColor: colorRojoBase(),
          foregroundColor: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(cliente.razon,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
            SizedBox(
              height: 5.0,
            ),
            Text(getFormatRut(cliente.rut)),
            SizedBox(
              height: 5.0,
            )
          ],
        ),
        trailing: IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              Navigator.pushNamed(context, 'venta', arguments: cliente);
            }),
      ),
    );
  }
}
