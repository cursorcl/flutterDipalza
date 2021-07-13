import 'package:dipalza_movil/src/bloc/productos_venta_bloc.dart';
import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/condicion-model.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/model/registro_item_model.dart';
import 'package:dipalza_movil/src/model/registro_item_resp_model.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProductoSelectPopUpWidget extends StatefulWidget {
  ProductosModel producto;
  ProductosVentaBloc productosVentaBloc;
  ClientesModel cliente;
  CondicionVentaModel condicionVenta;
  String fecha;

  ProductoSelectPopUpWidget(
      {@required this.producto,
      @required this.productosVentaBloc,
      @required this.cliente,
      @required this.condicionVenta,
      @required this.fecha});

  @override
  _ProductoSelectPopUpWidgetState createState() =>
      _ProductoSelectPopUpWidgetState();
}

class _ProductoSelectPopUpWidgetState extends State<ProductoSelectPopUpWidget> {
  final _cantidad = TextEditingController();
  final _descuento = TextEditingController();
  bool _blockBtn = true;

  @override
  Widget build(BuildContext context) {
    return _createPopUp(context, widget.producto);
  }

  AlertDialog _createPopUp(BuildContext context, ProductosModel producto) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: Text('Código: ' + producto.articulo, style: TextStyle(color: producto.stock > 0 ? Colors.green : Colors.red)),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(producto.descripcion,style: TextStyle(fontWeight: FontWeight.bold),),
            SizedBox(height: 5.0,),
            Text('Valor Neto: ' +getValorModena(producto.ventaneto.toDouble(), 0)),
            SizedBox(height: 5.0,),
            producto.numbered
                ? Row(
                    children: <Widget>[
                      Expanded(
                          child: Text('Piezas: ' +
                              getValorNumero(
                                  producto.pieces > 0 ? producto.pieces : 0))),
                      Expanded(
                          child: Text('Kilos: ' +
                              getValorNumeroDecimal(
                                  producto.stock > 0 ? producto.stock : 0, 2))),
                    ],
                  )
                : Text(
                    'Stock: ' +
                        getValorNumero(producto.stock > 0 ? producto.stock : 0),
                    style: TextStyle(
                        color: producto.stock > 0 ? Colors.black : Colors.red)),
            SizedBox(
              height: 5.0,
            ),

            Container(
                width: 30.0,
                child: TextField(
                  controller: _descuento,
                  onChanged: (value) {
                    if (value != '' && double.parse(value) >= 0 &&  double.parse(value) <= 100 && (_cantidad.text != '' && int.parse(_cantidad.text) > 0)) {
                      _blockBtn = false;
                    } else {
                      _blockBtn = true;
                    }
                    setState(() {});
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '% Descuento',
                  ),
                )),
            SizedBox(
              height: 5.0,
            ),
            Container(
                width: 30.0,
                child: TextField(
                  controller: _cantidad,
                  onChanged: (value) {
                    if (value != '' && int.parse(value) > 0  && (_descuento.text != '' && double.parse(_descuento.text) >= 0 &&  double.parse(_descuento.text) <= 100)) {
                      _blockBtn = false;
                    } else {
                      _blockBtn = true;
                    }
                    setState(() {});
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: producto.numbered ? 'Piezas' : 'Cantidad',
                  ),
                ))
          ],
        ),
      ),
      actions: <Widget>[
        Container(
          width: 100.0,
          child: RaisedButton(
            child: Container(
              child: Text('Cancelar'),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 0.0,
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _cantidad.text = '';
                _descuento.text = '0';
                Navigator.of(context).pop();
              });
            },
          ),
        ),
        Container(
          width: 100.0,
          child: RaisedButton(
            child: Container(
              child: Text('Agregar'),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 0.0,
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: _blockBtn
                ? null
                : () {
                    setState(() {
                      _registrarItem(producto, widget.cliente,
                          int.parse(_cantidad.text), double.parse(_descuento.text), widget.condicionVenta, context);
                    });
                  },
          ),
        ),
      ],
    );
  }

  void _registrarItem(ProductosModel producto, ClientesModel cliente,
      int cantidad, double descuento, CondicionVentaModel condicionVenta, BuildContext context) async {
    final prefs = new PreferenciasUsuario();
    final registro = RegistroItemModel();

    registro.indice = 0;
    registro.fila = 0;
    registro.rut = cliente.rut;
    registro.codigo = cliente.codigo;
    registro.vendedor = prefs.vendedor;
    registro.articulo = producto.articulo;
    registro.cantidad = cantidad;
    registro.descuento = descuento;
    registro.esnumerado = producto.numbered;
    registro.fecha = widget.fecha;
    registro.condicionventa = condicionVenta.codigo;

    if (!producto.numbered && cantidad > producto.stock) {
      registro.sobrestock = true;
    } else if (producto.numbered && cantidad > producto.pieces) {
      registro.sobrestock = true;
    } else {
      registro.sobrestock = false;
    }

    producto.registroItem = registro;

    print('envio');
    print(registroItemModelToJson(registro));

    RegistroItemRespModel registrado =
        await VentaProvider.ventaProvider.registrarItem(registro, context);

    // print('respuesta');
    //print(registroItemRespModelToJson(registrado));

    producto.registroItemResp = registrado;
    _cantidad.text = '';
    widget.productosVentaBloc.agregarProducto(producto);
    setState(() {});
    Navigator.of(context).pop();
  }
}
