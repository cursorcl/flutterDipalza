import 'package:dipalza_movil/src/bloc/productos_venta_bloc.dart';
import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/condicion_venta_model.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/model/venta_detalle_item_model.dart';
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
      {required this.producto,
      required this.productosVentaBloc,
      required this.cliente,
      required this.condicionVenta,
      required this.fecha});

  @override
  _ProductoSelectPopUpWidgetState createState() =>
      _ProductoSelectPopUpWidgetState();
}

class _ProductoSelectPopUpWidgetState extends State<ProductoSelectPopUpWidget> {
  final _cantidadCtrl = TextEditingController();
  final _descuentoCtrl = TextEditingController(text: '0');
  bool _blockBtn = true; // El estado del botón

  @override
  Widget build(BuildContext context) {
    return _createPopUp(context, widget.producto);
  }

// La función que crea el AlertDialog, ahora mucho más limpio
  AlertDialog _createPopUp(BuildContext context, ProductosModel producto) {
    // Función de validación unificada
    void _updateButtonState() {
      final bool isCantidadValid = _cantidadCtrl.text.isNotEmpty &&
          int.tryParse(_cantidadCtrl.text) != null &&
          int.parse(_cantidadCtrl.text) > 0;
      final bool isDescuentoValid = _descuentoCtrl.text.isNotEmpty &&
          double.tryParse(_descuentoCtrl.text) != null &&
          double.parse(_descuentoCtrl.text) >= 0 &&
          double.parse(_descuentoCtrl.text) <= 100;

      // Si la cantidad es válida y el descuento también, habilita el botón.
      // Usamos el estado del stock para habilitar el botón también
      setState(() {
        _blockBtn =
            !(isCantidadValid && isDescuentoValid && producto.stock > 0);
      });
    }

    // Ahora el AlertDialog con el nuevo diseño
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      scrollable: true,
      title: Text(
        'Código: ${producto.articulo}',
        style: TextStyle(
          color: producto.stock > 0 ? Colors.green : Colors.red,
          fontSize: 16,
        ),
      ),
      content: SizedBox(
        // Lo dejamos por si el contenido es muy grande
        width: double.maxFinite,
        child: Column(
          // Usamos Column en lugar de ListBody
          mainAxisSize:
              MainAxisSize.min, // Para que la columna ocupe el mínimo espacio
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              producto.descripcion,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(height: 5.0),
            Text(
                'Valor Neto: ${getValorModena(producto.ventaneto.toDouble(), 0)}'),
            SizedBox(height: 5.0),
            // Sección de stock/piezas
            producto.numbered
                ? Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                            'Piezas: ${getValorNumero(producto.pieces > 0 ? producto.pieces : 0)}'),
                      ),
                      Expanded(
                        child: Text(
                            'Kilos: ${getValorNumeroDecimal(producto.stock > 0 ? producto.stock : 0, 2)}'),
                      ),
                    ],
                  )
                : Text(
                    'Stock: ${getValorNumero(producto.stock > 0 ? producto.stock : 0)}',
                    style: TextStyle(
                        color: producto.stock > 0 ? Colors.black : Colors.red),
                  ),
            SizedBox(height: 10.0), // Espacio extra para los TextFields
            // TextField para el descuento
            TextField(
              controller: _descuentoCtrl,
              onChanged: (value) => _updateButtonState(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '% Descuento',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            SizedBox(height: 10.0),
            // TextField para la cantidad
            TextField(
              controller: _cantidadCtrl,
              onChanged: (value) => _updateButtonState(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: producto.numbered ? 'Piezas' : 'Cantidad',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(children: [
          ElevatedButton(
            child: FittedBox(
              fit: BoxFit
                  .scaleDown, // Para que solo se escale hacia abajo si no cabe
              child: Text('Cancelar'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .onError, // Estilo para el botón de cancelar
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              _cantidadCtrl.text = '';
              _descuentoCtrl.text = '0';
              Navigator.of(context).pop();
            },
          ),
          SizedBox(width: 10.0), // Espacio entre botones
          ElevatedButton(
            child: FittedBox(
              fit: BoxFit
                  .scaleDown, // Para que solo se escale hacia abajo si no cabe
              child: Text('Agregar'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: _blockBtn
                ? null
                : () {
                    // Lógica para agregar
                    _registrarItem(
                      producto,
                      widget.cliente,
                      int.parse(_cantidadCtrl.text),
                      double.parse(_descuentoCtrl.text),
                      widget.condicionVenta,
                      context,
                    );
                  },
          ),
        ])
      ],
    );
  }

  void _registrarItem(
      ProductosModel producto,
      ClientesModel cliente,
      int cantidad,
      double descuento,
      CondicionVentaModel condicionVenta,
      BuildContext context) async {
      final prefs = new PreferenciasUsuario();
      var registro;
/*    final registro = VentaDetalleItemModel();

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

    producto.registroItem = registro;*/

    print('envio');
    print(ventaDetalleItemModelToJson(registro));

    RegistroItemRespModel registrado =
        await VentaProvider.ventaProvider.registrarItem(registro, context);

    // print('respuesta');
    //print(registroItemRespModelToJson(registrado));

    producto.registroItemResp = registrado;
    _cantidadCtrl.text = '';
    widget.productosVentaBloc.agregarProducto(producto);
    setState(() {});
    Navigator.of(context).pop();
  }
}
