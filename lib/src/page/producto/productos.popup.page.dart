import 'package:dipalza_movil/src/bloc/productos_bloc.dart';
import 'package:dipalza_movil/src/bloc/productos_venta_bloc.dart';
import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/producto.select.popup.widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProductosPopUpPage extends StatefulWidget {
  ClientesModel cliente;
  String fecha;
  ProductosVentaBloc productosVentaBloc;

  ProductosPopUpPage(
      {@required this.cliente,
      @required this.fecha,
      @required this.productosVentaBloc});

  @override
  _ProductosPopUpPageState createState() => _ProductosPopUpPageState();
}

class _ProductosPopUpPageState extends State<ProductosPopUpPage> {
  TextEditingController controller = new TextEditingController();
  List<ProductosModel> _searchResult = [];
  List<ProductosModel> _listaProductos = [];

  Future<Null> getListaProductos() async {
    _listaProductos = ProductosBloc().listaProductos;
    // _listaProductos =
    //     await ProductosProvider.productosProvider.obtenerListaProductos();
    setState(() {});
  }

  Future<void> getListaProductosRefrescar() async {
    getListaProductos();
    onSearchTextChanged(controller.text);
  }

  @override
  void initState() {
    getListaProductos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> lista = [];
    final size = MediaQuery.of(context).size;

    lista.addAll(_creaListaProductos(context, _searchResult));

    return Column(children: [
      Container(width: size.width * 0.9, child: _creaInputBuscar(context)),
      Column(
        children: lista,
      ),
    ]);
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
    if (text.isEmpty || text.length < 2) {
      setState(() {});
      return;
    }

    _listaProductos.forEach((producto) {
      if (producto.descripcion.toUpperCase().contains(text.toUpperCase()) ||
          producto.articulo == text) _searchResult.add(producto);
    });

    setState(() {});
  }

  List<Widget> _creaListaProductos(
      BuildContext context, List<ProductosModel> listaProductos) {
    final List<Widget> _listItem = [];

    if (listaProductos.length == 0) {
      _listItem.add(Container(
        height: 50.0,
        child: Center(child: Text('Sin Resultados')),
      ));
      return _listItem;
    }

    listaProductos.forEach((producto) {
      _listItem.add(_creaCard(context, producto));
    });
    setState(() {});
    return _listItem;
  }

  _creaCard(BuildContext context, ProductosModel producto) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          child: Icon(Icons.card_giftcard),
          backgroundColor: colorRojoBase(),
          foregroundColor: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(producto.descripcion,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
            SizedBox(
              height: 5.0,
            ),
            Text('Código: ' + producto.articulo),
            SizedBox(
              height: 5.0,
            )
          ],
        ),
        trailing: IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              return showDialog<void>(
                  context: context,
                  // barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return ProductoSelectPopUpWidget(
                      producto: producto,
                      productosVentaBloc: widget.productosVentaBloc,
                      cliente: widget.cliente,
                      fecha: widget.fecha,
                    );
                  }).then((value) => setState(() {
                    Navigator.of(context).pop();
                  }));
            }),
      ),
    );
  }
}
