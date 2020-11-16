import 'package:dipalza_movil/src/bloc/productos_bloc.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/provider/productos_provider.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({Key key}) : super(key: key);

  @override
  _ProductosPageState createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final productosBloc = new ProductosBloc();
  TextEditingController controller = new TextEditingController();
  List<ProductosModel> _searchResult = [];
  List<ProductosModel> _listaProductos = [];
  bool _verBuscar = false;


  Future<Null> getListaProductos() async {
     _listaProductos = await ProductosProvider.productosProvider.obtenerListaProductos();
     setState(() {});
  }

   @override
  void initState() {
    super.initState();
    getListaProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: Container(
          child: Center(
            child: Text(
              'Productos',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () {setState(() {
              _verBuscar = true;
            });},
          ),
        ],
      ),
      // body: Column(
      //   children: <Widget>[
      //     // FondoWidget(),
      //     _creaListaProductos(context),
      //   ],
      // ),
      body: Column(
        children: <Widget>[
          _verBuscar ? _creaInputBuscar(context) : Container(),
          Expanded(child: _searchResult.length != 0 || controller.text.isNotEmpty ? _creaListaProductos(context, _searchResult) : _creaListaProductos(context, _listaProductos)),
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
                    trailing: new IconButton(icon: new Icon(Icons.cancel), onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                      setState(() {
                        _verBuscar = false;
                      });
                    },),
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

    productosBloc.listaProductos.forEach((producto) {
      if (producto.descripcion.contains(text))
        _searchResult.add(producto);
    });

    setState(() {});
  }

  Widget _creaListaProductos(BuildContext context, List<ProductosModel> listaProducto) {
    return ListView.builder(
              itemCount: listaProducto.length,
              
              itemBuilder: (context, i) {
                return _creaCard(listaProducto[i]);
              },
            );
    // return StreamBuilder(
    //   stream: productosBloc.productosStream,
    //   builder:
    //       (BuildContext context, AsyncSnapshot<List<ProductosModel>> snapshot) {
    //     if (snapshot.hasData) {
    //       if (snapshot.data != null && snapshot.data.length > 0) {
    //         return RefreshIndicator(
    //           onRefresh: _recargar,
    //           child: ListView(
    //             children: _listaProductosItems(snapshot.data, context),
    //           ),
    //         );
    //       } else {
    //         return Center(
    //           child: Text('No Existen Operaciones'),
    //         );
    //       }
    //     } else {
    //       return Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     }
    //   },
    // );
  }

  _creaCard(ProductosModel producto) {
    return Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                child: Icon(Icons.card_giftcard),
                backgroundColor: colorRojoBase(),
                foregroundColor: Colors.white,
              ),
              title: Text(producto.descripcion,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: Colors.black)),
              subtitle: Row(
                children: <Widget>[
                  detalleProducto(producto),
                  Expanded(child: Container()),
                  btnLoad(producto)
                ],
              ),
              trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios), onPressed: () {}),
            ),
          );
  }

  Future<Null> _recargar() async {
    productosBloc.obtenerListaProductos();
  }

  List<Widget> _listaProductosItems(
      List<ProductosModel> data, BuildContext context) {
    final List<Widget> _listItem = [];

    data?.forEach((producto) {
      _listItem
        ..add(
          Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                child: Icon(Icons.card_giftcard),
                backgroundColor: colorRojoBase(),
                foregroundColor: Colors.white,
              ),
              title: Text(producto.descripcion,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: Colors.black)),
              subtitle: Row(
                children: <Widget>[
                  detalleProducto(producto),
                  Expanded(child: Container()),
                  btnLoad(producto)
                ],
              ),
              trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios), onPressed: () {}),
            ),
          ),
        );
    });

    return _listItem;
  }

  Column detalleProducto(ProductosModel producto) {
    FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
        amount: producto.ventaneto.toDouble(),
        settings: MoneyFormatterSettings(
            // symbol: 'IDR',
            thousandSeparator: '.',
            decimalSeparator: ',',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 0,
            compactFormatType: CompactFormatType.short));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 5.0,
        ),
        Text(
          fmf.output.symbolOnLeft + '.-',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
        ),
        SizedBox(
          height: 2.0,
        ),
        Text(unidadValuesDetalle.reverse[producto.unidad],
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                color: Colors.grey)),
      ],
    );
  }

  Column btnLoad(ProductosModel producto) {
    FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
        amount: producto.stock,
        settings: MoneyFormatterSettings(
            symbol: '',
            thousandSeparator: '.',
            decimalSeparator: ',',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 0,
            compactFormatType: CompactFormatType.short));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(color: Colors.grey)),
            padding: EdgeInsets.all(4.0),
            onPressed: () => productosBloc.obtenerListaProductos(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 2.0,
                ),
                Icon(
                  Icons.autorenew,
                  size: 18.0,
                ),
                Text(
                  fmf.output.symbolOnLeft + ' Unidades',
                  style: TextStyle(
                      color: producto.stock > 0 ? Colors.green : Colors.red,
                      fontSize: 12.0),
                ),
                SizedBox(
                  height: 2.0,
                ),
              ],
            )),
      ],
    );
  }
}
