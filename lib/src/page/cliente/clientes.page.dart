import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/inicio_venta_model.dart';
import 'package:dipalza_movil/src/provider/cliente_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({Key? key}) : super(key: key);

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
        .obtenerListaClientes(prefs.vendedor, prefs.ruta, context);
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
    bool searchResult = _searchResult.length != 0 || controller.text.isNotEmpty;
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
      body: Stack(
        children: <Widget>[
          // 1. FondoWidget() debe estar en la capa más baja del Stack.
          Positioned.fill(
            child: FondoWidget(),
          ),
          // 2. El resto del contenido (input y lista) debe ir en una Column
          //    para que el Expanded funcione.
          //    Usamos un Positioned.fill para que la Column ocupe todo el espacio.
          Positioned.fill(
          child: Column(
              children: <Widget>[
                  // El input de búsqueda (se mostrará o no)
                  _verBuscar ? _creaInputBuscar(context) : Container(),
                  searchResult ? _creaListaClientes(context, _searchResult) : _creaListaClientes(context, _listaClientes)
              ],
            ),
          ),
        ]
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
      return _createEmptyCard();
      //Center(
      //  child: Text('No existen Clientes para la conbinación Vendedor / Ruta.'),
      //);
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

  _createEmptyCard() {
    return Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            child: Icon(Icons.account_box),
            backgroundColor: colorRojoBase(),
            foregroundColor: Colors.white,
          ),
          title: Text('No existen Clientes para la conbinación Vendedor / Ruta.'),
    ));
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
            Text(cliente.razon,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                )),
            SizedBox(
              height: 2.0,
            ),
            Text(getFormatRut(cliente.rut),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                )),
            SizedBox(
              height: 5.0,
            )
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(cliente.direccion, style: TextStyle(fontSize: 12.0)),
            Text(cliente.telefono, style: TextStyle(fontSize: 12.0))
          ],
        ),
        trailing: IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              Navigator.pushNamed(context, 'venta',
                  arguments: new InicioVentaModel(cliente: cliente));
            }),
      ),
    );
  }
}
