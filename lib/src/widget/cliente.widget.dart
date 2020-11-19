import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/provider/cliente_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

class ClientesWidget extends StatefulWidget {
  ClientesWidget({Key key}) : super(key: key);

  @override
  _ClientesWidgetState createState() => _ClientesWidgetState();
}

class _ClientesWidgetState extends State<ClientesWidget> {
  TextEditingController controller = new TextEditingController();
  List<ClientesModel> _searchResult = [];
  List<ClientesModel> _listaClientes = [];
  SimpleDialog dialog = new SimpleDialog();

  Future<Null> getListaClientes() async {
    final prefs = new PreferenciasUsuario();
    _listaClientes = await ClientesProvider.clientesProvider
        .obtenerListaClientes(prefs.code, prefs.ruta);
    setState(() {});
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

    print('paso');
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
    print('paso2');
    this.dialog = SimpleDialog(
      title: Center(child: Text('Selección de Cliente')),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      children: _searchResult.length != 0 || controller.text.isNotEmpty ? _creaListaClientes(context, _searchResult) : _creaListaClientes(context, _listaClientes),      
    );

    return FloatingActionButton(
      // onPressed: () => Navigator.pushNamed(context, 'venta'),
      onPressed: () {
        showDialog<void>(context: context, builder: (context) => this.dialog);
      },
      backgroundColor: HexColor('#ff7043'),
      tooltip: 'Ingresar Venta',
      child: Icon(
        Icons.add,
        size: 35.0,
      ),
    );
  }

  Widget _creaInputBuscar(BuildContext context) {
    return AnimatedOpacity(
      // opacity: _verBuscar ? 1.0 : 0.0,
      opacity: 1.0,
      duration: Duration(milliseconds: 500),
      child: Container(
        // color: colorRojoBase(),
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
                    // _verBuscar = false;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _creaListaClientes(
      BuildContext context, List<ClientesModel> listaCliente) {
    final List<Widget> _listItem = [];
    _listItem.add(_creaInputBuscar(context));

    listaCliente.forEach((cliente) {
      _listItem.add(_creaCard(cliente));
    });
print('paso3');

    setState(() {
      
    });
    return _listItem;

    // return RefreshIndicator(
    //       onRefresh: getListaClientesRefrescar,
    //       child: ListView.builder(
    //             itemCount: listaCliente.length,
    //             itemBuilder: (context, i) {
    //               return _creaCard(listaCliente[i]);
    //             },
    //           ),
    // );
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
            Text(cliente.rut),
            SizedBox(
              height: 5.0,
            )
          ],
        ),
        // subtitle: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: <Widget>[
        //     Text(producto.direccion),
        //     Text(producto.telefono)
        //   ],
        // ),
        trailing:
            IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: () {}),
      ),
    );
  }
}
