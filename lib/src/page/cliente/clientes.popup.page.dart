import 'package:dipalza_movil/src/bloc/condicion_venta_bloc.dart';
import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/condicion_venta_model.dart';
import 'package:dipalza_movil/src/model/inicio_venta_model.dart';
import 'package:dipalza_movil/src/provider/cliente_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientesPopUpPage extends StatefulWidget {
  const ClientesPopUpPage({Key? key}) : super(key: key);

  @override
  _ClientesPopUpPageState createState() => _ClientesPopUpPageState();
}

class _ClientesPopUpPageState extends State<ClientesPopUpPage> {


  TextEditingController controller = new TextEditingController();
  List<ClientesModel> _searchResult = [];
  List<ClientesModel> _listaClientes = [];

  List<CondicionVentaModel> _listaCondicionVenta = [];
  CondicionVentaModel? _condicionSeleccionada;

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

  Future<Null> getListaCondicionVenta() async {
    CondicionVentaBloc().obtenerListaCondicionesVenta();
    _listaCondicionVenta =  CondicionVentaBloc().listaCondicionVenta;
    _condicionSeleccionada = _listaCondicionVenta[0] ?? null;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getListaClientes();
    getListaCondicionVenta();
  }

  @override
  Widget build(BuildContext context) {
    final condicionVentaBloc = Provider.of<CondicionVentaBloc>(context, listen: false);
    final List<Widget> lista = [];
    lista.add(_crearCondicionPago(context));
    lista.add(_creaInputBuscar(context));
    lista.addAll(_creaListaClientes(
        context,
        _searchResult.length != 0 || controller.text.isNotEmpty
            ? _searchResult
            : _listaClientes));
    

    return Column(
      children: lista,
    );
  }

  Widget _crearCondicionPago(BuildContext context) {
    return Container(
      child:  new Card(
            child: InputDecorator(
                decoration: InputDecoration( labelStyle: TextStyle(color: Colors.redAccent, fontSize: 14.0), hintText: 'Condición de Pago', border: InputBorder.none),
                isEmpty: _condicionSeleccionada == null,
                child:  _crearComboCondicionVenta(context),
            )
          ),
    );
  }

  Widget _creaInputBuscar(BuildContext context) {
    return Container(
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
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    List<ClientesModel> result = _listaClientes.where((cliente) => cliente.razon.toLowerCase().contains(text.toLowerCase())).toList();
    if (result == null || result.isEmpty) {
      setState(() {});
      return;
    }
    _searchResult.addAll(result);
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
          radius: 16,
          child: Icon(Icons.account_circle_outlined),
          backgroundColor: _condicionSeleccionada == null ? Colors.grey : colorRojoBase(),
          foregroundColor: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(cliente.razon,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0, color: _condicionSeleccionada == null ? Colors.grey : Colors.black)),
            SizedBox(
              height: 3.0,
            ),
            Text(getFormatRut(cliente.rut),
              style: TextStyle( fontSize: 11.0, color: _condicionSeleccionada == null ? Colors.grey : Colors.black)),
          ],
        ),
        trailing: IconButton(
            disabledColor: Colors.blueGrey,
            icon: Icon( Icons.arrow_forward_ios),
            onPressed: () {
              if(_condicionSeleccionada == null) return null;
              Navigator.pushNamed(context, 'venta', arguments: new InicioVentaModel(cliente: cliente, condicionVenta: _condicionSeleccionada));
            }),
      ),
    );
  }



  Widget _crearComboCondicionVenta(BuildContext context) {
    return new Container(
      child: new Center(
          child: new DropdownButtonFormField(
            value: _condicionSeleccionada,
            items: getOpcionesDropDown(),
            onChanged: changedDropDownItem,
            style: const TextStyle(color: Colors.black),
          )
      )      
    );
  }

  void changedDropDownItem(CondicionVentaModel? selectedCity) {
    setState(() {
      _condicionSeleccionada = selectedCity;
    });
  }

 List<DropdownMenuItem<CondicionVentaModel>> getOpcionesDropDown() {
    
    List<DropdownMenuItem<CondicionVentaModel>> lista = [];

    if(_listaCondicionVenta == null) return [];

    _listaCondicionVenta.forEach((condicion) {
      lista.add(DropdownMenuItem(
        child: Text(condicion.descripcion, style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                ),
                textAlign: TextAlign.right,
                ),
        value: condicion,
      ));
    });

    return lista;
  }

  List<Widget> getSelectedOpcionsDropDown(BuildContext context) {
    
    List<Widget> lista = [];

    if(_listaCondicionVenta == null) return [];

    _listaCondicionVenta.forEach((condicion) {
      lista.add( 
        Text(
          condicion.descripcion, 
          style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                color: Colors.white
          ),
          textAlign: TextAlign.right,
        ),
      );
    });

    return lista;
  }  
}
