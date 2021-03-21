import 'dart:math';

import 'package:dipalza_movil/src/bloc/productos_venta_bloc.dart';
import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/inicio_venta_model.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/page/producto/productos.popup.page.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({Key key}) : super(key: key);

  @override
  _VentasPageState createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  int _valorItems = 0;
  double _valorNeto = 0.0;
  double _valorIla = 0.0;
  double _valorIva = 0.0;
  double _valorTotal = 0.0;
  double _valorCarne = 0.0;
  final productoVentaBloc = ProductosVentaBloc();
  String _fecha = '';
  Widget _widgetResumenVenta;
  bool _primeraCarga = true;

  @override
  void initState() {
    print('>>>>>>>>> INIT STATE >>>>>>>>>');
    super.initState();
    this.productoVentaBloc.limpiarProductos();
    this._fecha = DateTime.now().millisecondsSinceEpoch.toString();
    print('FECHA DEL REGISTRO: ' + this._fecha);
  }

  @override
  Widget build(BuildContext context) {
    print('>>>>>>>>> BUILD STATE >>>>>>>>>');
    // ClientesModel _cliente = ModalRoute.of(context).settings.arguments;
    InicioVentaModel _inicioVenta = ModalRoute.of(context).settings.arguments;

    if (this._primeraCarga &&
        _inicioVenta.listaVentaItem != null &&
        _inicioVenta.listaVentaItem.isNotEmpty) {
      for (ProductosModel producto in _inicioVenta.listaVentaItem) {
        this._fecha =
            producto.registroItemResp.fecha.millisecondsSinceEpoch.toString();
        this.productoVentaBloc.agregarProducto(producto);
      }
      this._primeraCarga = false;
      //  this._fecha = _inicioVenta.listaVentaItem[0].registroItemResp.fecha.millisecondsSinceEpoch.toString();

    }

    List<ProductosModel> _listaVenta = this.productoVentaBloc.listaProductos;
    this._widgetResumenVenta = this.loadResumenVenta();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushNamed(context, 'home')),
        title: Container(
          child: Center(
            child: Text(
              'Ingresar Venta',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        child: Column(
          children: <Widget>[
            _creaCabeceraCliente(context, _inicioVenta.cliente),
            _creaCabeceraResumen(context, _inicioVenta.cliente),
            Expanded(
              child: _creaListaProductos(context, _listaVenta),
            )
          ],
        ),
      ),
    );
  }

  _creaCabeceraCliente(BuildContext context, ClientesModel _cliente) {
    return Container(
        color: colorRojoBase(),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15.0, bottom: 5.0),
                  child: CircleAvatar(
                    radius: 25,
                    child: Icon(
                      Icons.account_box,
                      size: 35.0,
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: colorRojoBase(),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _cliente.razon,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(getFormatRut(_cliente.rut),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ))
                    ],
                  ),
                )
              ],
            )
          ],
        ));
  }

  _creaCabeceraResumen(BuildContext context, ClientesModel _cliente) {
    final size = MediaQuery.of(context).size;

    return Container(
        color: colorRojoBase(),
        child: Row(
          children: <Widget>[
            Container(
              width: size.width * 0.35,
              alignment: Alignment.center,
              child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  tooltip: 'Ingresar Venta',
                  child: Icon(
                    Icons.add_shopping_cart,
                    size: 35.0,
                  ),
                  onPressed: () {
                    showDialog<void>(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: Center(child: Text('Selección de Producto')),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            children: <Widget>[
                              ProductosPopUpPage(
                                cliente: _cliente,
                                fecha: _fecha,
                                productosVentaBloc: productoVentaBloc,
                              ),
                              SizedBox(
                                height: 10.0,
                              )
                            ],
                          );
                        }).then((value) => setState(() {}));

                    setState(() {});
                  }),
            ),
            this._widgetResumenVenta,
          ],
        ));
  }

  Widget getCeldaTexto(String valor) {
    return Container(
      alignment: Alignment.centerRight,
      child: Text(
        valor,
        style: TextStyle(color: Colors.white, fontSize: 15.0),
      ),
    );
  }

  Widget getCeldaMoneda(double valor) {
    return Container(
      alignment: Alignment.centerRight,
      child: Text(
        getValorModena(valor, 2),
        style: TextStyle(color: Colors.white, fontSize: 15.0),
      ),
    );
  }

  Widget _creaListaProductos(
      BuildContext context, List<ProductosModel> _listaVenta) {
    return ListView(
      shrinkWrap: true,
      children: _listaItem(context, _listaVenta),
    );
  }

  List<Widget> _listaItem(BuildContext context, List<ProductosModel> lista) {
    final List<Widget> opciones = [];

    lista.forEach((prod) {
      Widget widgetTemp = Dismissible(
          key: Key(prod.articulo +
              prod.registroItemResp.cantidad.toString() +
              Random().nextInt(10000).toString()),
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            color: Colors.red,
            child: Icon(Icons.delete_forever, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (DismissDirection direction) {
            print(direction.toString());
            if (direction == DismissDirection.endToStart) {
              this._removerItem(prod);
            }
          },
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 20,
                child: Icon(Icons.card_giftcard),
                backgroundColor: colorRojoBase(),
                foregroundColor: Colors.white,
              ),
              title: Text(
                  prod.descripcion +
                      ' - ' +
                      prod.registroItemResp.indice.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: Colors.black)),
              subtitle: Row(
                children: <Widget>[
                  detalleProducto(prod),
                  Expanded(child: Container()),
                  detalleSolicitado(prod),
                ],
              ),
            ),
          ));

      opciones..add(widgetTemp);
    });
    setState(() {});

    return opciones;
  }

  Widget loadResumenVenta() {
    final size = MediaQuery.of(context).size;
    this._valorIla = 0;
    this._valorCarne = 0;
    this._valorItems = 0;
    this._valorNeto = 0;
    this._valorIva = 0;
    this._valorTotal = 0;

    List<ProductosModel> lista = productoVentaBloc.listaProductos;

    this._valorItems = lista.length;

    lista.forEach((prod) {
      this._valorNeto = this._valorNeto + prod.registroItemResp.neto;
      this._valorIla = this._valorIla + prod.registroItemResp.ila;
      this._valorCarne = this._valorCarne + prod.registroItemResp.carne;
      this._valorIva = this._valorIva + prod.registroItemResp.iva;
      this._valorTotal =
          this._valorNeto + this._valorIla + this._valorCarne + this._valorIva;
    });

    return Container(
      padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
      width: size.width * 0.65,
      child: Table(
        children: [
          TableRow(children: [
            getCeldaTexto('Items:'),
            getCeldaTexto(this._valorItems.toString())
          ]),
          TableRow(children: [
            getCeldaTexto('Venta Neta:'),
            getCeldaMoneda(this._valorNeto)
          ]),
          TableRow(children: [
            getCeldaTexto('ILA:'),
            getCeldaMoneda(this._valorIla)
          ]),
          TableRow(children: [
            getCeldaTexto('Carne:'),
            getCeldaMoneda(this._valorCarne)
          ]),
          TableRow(children: [
            getCeldaTexto('IVA:'),
            getCeldaMoneda(this._valorIva)
          ]),
          TableRow(children: [
            getCeldaTexto('Total:'),
            getCeldaMoneda(this._valorTotal)
          ])
        ],
      ),
    );
  }

  Column detalleProducto(ProductosModel producto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 5.0,
        ),
        Text(
          getValorModena(producto.ventaneto.toDouble(), 0),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
        ),
        SizedBox(
          height: 2.0,
        ),
        Text('Unidad: ' + producto.unidad,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                color: Colors.grey)),
      ],
    );
  }

  Column detalleSolicitado(ProductosModel producto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: 5.0,
        ),
        // Text(
        //   producto.numbered
        //       ? 'Piezas Solicitadas: ' +
        //           producto.registroItem.cantidad.toString()
        //       : 'Cantidad Solicitada: ' +
        //           producto.registroItem.cantidad.toString(),
        //   style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.0),
        // ),
        // SizedBox(
        //   height: 2.0,
        // ),
        Text(
          producto.numbered
              ? 'Kilos Confirmados: ' +
                  producto.registroItemResp.cantidad.toString()
              : 'Cantidad Confirmada: ' +
                  getValorNumero(producto.registroItemResp.cantidad),
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.0),
        ),
      ],
    );
  }

  void _removerItem(ProductosModel producto) async {
    bool resp = await VentaProvider.ventaProvider
        .removerItem(producto, context, productoVentaBloc);

    if (resp) {
      this.loadResumenVenta();
      setState(() {});
    }
  }
}
