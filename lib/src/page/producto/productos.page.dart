// import 'package:dipalza_movil/src/bloc/productos_bloc.dart';
import 'package:dipalza_movil/src/bloc/productos_bloc.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({Key? key}) : super(key: key);

  @override
  _ProductosPageState createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  // final productosBloc = new ProductosBloc();
  TextEditingController controller = new TextEditingController();
  List<ProductosModel> _searchResult = [];
  List<ProductosModel> _listaProductos = [];
  bool _verBuscar = false;



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
            onPressed: () {
              setState(() {
                _verBuscar = true;
              });
            },
          ),
        ],
      ),
      // body: Column(
      //   children: <Widget>[
      //     // FondoWidget(),
      //     _creaListaProductos(context),
      //   ],
      // ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: FondoWidget(),
          ),
          Positioned.fill(
            child: Column(
              children: <Widget>[
                // El input de búsqueda (se mostrará o no)
                _verBuscar ? _creaInputBuscar(context) : Container(),

                // La lista de productos, que ahora sí puede expandirse
                // para ocupar el espacio restante.
                Expanded(
                  child: _searchResult.length != 0 || controller.text.isNotEmpty
                      ? _creaListaProductos(context, _searchResult)
                      : _creaListaProductos(context, _listaProductos),
                ),
              ],
            ),
          ),
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

    _listaProductos.forEach((producto) {
      if (producto.descripcion.toUpperCase().contains(text.toUpperCase()) ||
          producto.articulo == text) _searchResult.add(producto);
    });

    setState(() {});
  }

  Widget _creaListaProductos(
      BuildContext context, List<ProductosModel> listaProducto) {
    if (listaProducto.length == 0) {
      return Center(
        child: Text('No existen Productos a mostrar.'),
      );
    }

    return RefreshIndicator(
      onRefresh: getListaProductosRefrescar,
      child: ListView.builder(
        itemCount: listaProducto.length,
        itemBuilder: (context, i) {
          return _creaCard(listaProducto[i]);
        },
      ),
    );
  }

  _creaCard(ProductosModel producto) {
    final stock = producto.stock > 0 ? producto.stock : 0;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          child: Icon(Icons.card_giftcard),
          backgroundColor: colorRojoBase(),
          foregroundColor: Colors.white,
        ),
        title: Text(
          producto.descripcion,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Precio:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '\$${producto.ventaneto.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'Stock:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${stock.toStringAsFixed(2)} ${producto.unidad}',
                  style:  TextStyle(fontWeight: FontWeight.bold, color: stock > 0 ? Colors.blueAccent : Colors.red,),
                ),
              ],
            ),
            if(producto.numbered)
              Row(
                children: [
                  const Text(
                    'Piezas:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    '${producto.pieces.toStringAsFixed(0)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: producto.pieces > 0 ? Colors.blueAccent : Colors.red,),
                  ),
                ],
              ),
          ],
        ),
/*        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {},
        ),*/
      ),
    );
  }


  Column btnLoad(ProductosModel producto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(color: Colors.grey)),
              padding: EdgeInsets.all(4.0),
            ),
            onPressed: () => getListaProductos(),
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
                  getValorNumero(producto.stock > 0 ? producto.stock : 0) +
                      ' Unidades',
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

  Future<Null> getListaProductos() async {
    ProductosBloc().obtenerListaProductos();
    _listaProductos = ProductosBloc().listaProductos;
    setState(() {});
  }

  Future<void> getListaProductosRefrescar() async {
    ProductosBloc();
    getListaProductos();
    onSearchTextChanged(controller.text);
  }
}
