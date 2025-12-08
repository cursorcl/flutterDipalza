import 'dart:developer' as developer;

import 'package:dipalza_movil/src/model/numerado_model.dart';
import 'package:dipalza_movil/src/model/venta_detalle_pieza_model.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/page/home/home2.page.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/app_routes.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart';
import 'package:flutter/material.dart';

import '../../bloc/productos_bloc.dart';
import '../../model/producto_model.dart';
import '../../model/venta_detalle_model.dart';
import '../../provider/productos_provider.dart';
import '../../share/app.navigator.dart';
import '../producto/productos.page.dart';

class VentaEdicionItemDetalle extends StatefulWidget {
  final VentaModel? actualVenta;
  final VentaDetalleModel? actualVentaDetalle; // si viene nulo, es nuevo

  const VentaEdicionItemDetalle({Key? key, this.actualVenta, this.actualVentaDetalle}) : super(key: key);

  @override
  _VentaEdicionItemDetalleState createState() => _VentaEdicionItemDetalleState();
}

class _VentaEdicionItemDetalleState extends State<VentaEdicionItemDetalle> {
  final ProductosProvider _productosProvider = ProductosProvider.productosProvider;
  final ProductsBloc _productosBloc = ProductsBloc();

  late TextEditingController _productoController;
  late TextEditingController _cantidadController;
  late TextEditingController _descuentoController;

  late FocusNode _productoFocusNode;
  late FocusNode _cantidadFocusNode;
  late FocusNode _descuentoFocusNode;
  late FocusNode _guardarFocusNode;

  ProductosModel? productoEnVenta = null;
  List<VentaDetallePiezaModel> numeradosEnVenta = [];

  bool _isBlocReady = false;

  String? _productoId;
  double _precioUnitario = 0;
  double _valorFinal = 0;
  double _pesoTotal = 0;
  bool _esNumerado = false;
  double _stockDisponible = 0;
  double _valorDescuento = 0;
  String _unidadProducto = 'un';
  double _porcentajeILA = 0;
  double _porcentajeIVA = 0;
  bool _estaCargandoStock = false;

  // Se utiliza para colocar rojo el borde del campo cantidad si excede el stock
  bool _excedeStock = false;

  @override
  void initState() {
    super.initState();
    _setupPagina();
  }

  Future<void> _setupPagina() async {
    await _productosBloc.initialLoadDone;

    final pref = PreferenciasUsuario();
    final d = widget.actualVentaDetalle;

    _productoFocusNode = FocusNode();
    _cantidadFocusNode = FocusNode();
    _descuentoFocusNode = FocusNode();
    _guardarFocusNode = FocusNode();

    _cantidadController = TextEditingController(text: d?.cantidad.toString() ?? '0');
    _descuentoController = TextEditingController(text: d?.totalDescuento.toString() ?? '0'); // '0' por defecto

    if (d != null) {
      final String claveBusqueda = d.idProducto;
      productoEnVenta = _productosBloc.searchProduct(claveBusqueda);
      if (productoEnVenta != null) {
        _productoId = productoEnVenta!.articulo;
        _productoController = TextEditingController(text: productoEnVenta!.descripcion);
        _precioUnitario = productoEnVenta!.ventaneto;
        _esNumerado = productoEnVenta!.numbered;
        _unidadProducto = productoEnVenta!.unidad;
        _porcentajeILA = productoEnVenta!.porcila;

        // tengo que generar la lista de piezas que ya tiene la venta.
        // ojo con esto, esta lista sirve mientras que no cambie el código de producto.
        if (_esNumerado) {
          for (var item in d.piezasDetalle) {
            numeradosEnVenta.add(item);
          }
        }

        _cargarStockProducto(productoEnVenta!.articulo);
      } else {
        _productoController = TextEditingController(text: d.nombreProducto);
        _precioUnitario = d.precioUnitario;
        _esNumerado = d.piezas > 0;
      }
      _porcentajeIVA = d.porcentajeIva;
    } else {
      productoEnVenta = null;
      _productoController = TextEditingController(text: '');
      _porcentajeIVA = pref.iva;
    }
    _addSelectAllListener(_productoFocusNode, _productoController);
    _addSelectAllListener(_cantidadFocusNode, _cantidadController);
    _addSelectAllListener(_descuentoFocusNode, _descuentoController);

    _recalcularTotal();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.actualVentaDetalle == null)
        FocusScope.of(context).requestFocus(_productoFocusNode);
      else
        FocusScope.of(context).requestFocus(_cantidadFocusNode);
    });
    setState(() {
      _isBlocReady = true;
    });
  }

  void _addSelectAllListener(FocusNode node, TextEditingController controller) {
    node.addListener(() {
      if (node.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _descuentoController.dispose();
    _cantidadFocusNode.dispose();
    _descuentoFocusNode.dispose();
    _guardarFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBlocReady) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.actualVentaDetalle == null ? 'Agregar producto' : 'Editar detalle'),
          backgroundColor: Colors.redAccent,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final double cantidadActual = double.tryParse(_cantidadController.text) ?? 0;
    final bool isDecrementDisabled = cantidadActual <= 0;
    final double descuentoActual = double.tryParse(_descuentoController.text) ?? 0;
    final bool isDescuentoDecrementDisabled = descuentoActual <= 0;
    final bool isDescuentoIncrementDisabled = descuentoActual >= 50;

    final bool enabled = _productoController.text.isNotEmpty;

    // UI PRINCIPAL
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.actualVentaDetalle == null ? 'Agregar producto' : 'Editar detalle'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.actualVentaDetalle == null)
              Autocomplete<ProductosModel>(
                initialValue: TextEditingValue(text: _productoController.text),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<ProductosModel>.empty();
                  }
                  return _productosBloc.searchProducts(textEditingValue.text);
                },
                displayStringForOption: (ProductosModel option) => option.descripcion,
                onSelected: (ProductosModel seleccion) {
                  _actualizarProductoSeleccionado(seleccion);
                  _cargarStockProducto(seleccion.articulo);
                },
                fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  // Sincroniza el controller de Autocomplete con el nuestro
                  _productoController = fieldTextEditingController;
                  _productoFocusNode = fieldFocusNode;
                  _addSelectAllListener(_productoFocusNode, _productoController);
                  return TextField(
                    controller: _productoController,
                    focusNode: _productoFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Buscar por Código o Nombre',
                      hintText: 'Escriba para buscar...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        tooltip: 'Buscar en lista completa',
                        onPressed: _buscarProducto,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (term) => _buscarProductoPorTermino(term),
                  );
                },
                optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<ProductosModel> onSelected, Iterable<ProductosModel> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ProductosModel option = options.elementAt(index);
                            return InkWell(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(option.descripcion),
                                subtitle: Text("Código: ${option.articulo}"),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              TextField(
                controller: _productoController,
                focusNode: _productoFocusNode,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Producto',
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle, size: 30),
                  color: Colors.redAccent,
                  disabledColor: Colors.grey[400],
                  onPressed: isDecrementDisabled ? null : _decrementarCantidad,
                ),
                Expanded(
                  child: TextField(
                    controller: _cantidadController,
                    focusNode: _cantidadFocusNode,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _excedeStock ? Colors.red : Colors.black),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: _excedeStock ? Colors.red : Colors.black,
                      ),
                    ),
                    onChanged: (_) => _recalcularTotal(),
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(_descuentoFocusNode),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green, size: 30),
                  onPressed: _incrementarCantidad,
                ),
              ],
            ),
            if (_esNumerado)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Peso total: ${_pesoTotal.toStringAsFixed(2)} kg',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle, size: 30),
                  color: Colors.redAccent,
                  disabledColor: Colors.grey[400],
                  onPressed: isDescuentoDecrementDisabled ? null : _decrementarDescuento,
                ),
                Expanded(
                  child: TextField(
                    controller: _descuentoController,
                    focusNode: _descuentoFocusNode,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(labelText: 'Descuento (%)'),
                    onChanged: (_) => _recalcularTotal(),
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(_guardarFocusNode),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, size: 30),
                  color: Colors.green,
                  disabledColor: Colors.grey[400],
                  onPressed: isDescuentoIncrementDisabled ? null : _incrementarDescuento,
                ),
              ],
            ),
            const Spacer(),
            _buildResumenInferior(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Guardar'),
              focusNode: _guardarFocusNode,
              onPressed: enabled ? _guardar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[400],
                disabledForegroundColor: Colors.grey[800],
                minimumSize: Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _incrementarCantidad() async {
    double cantidad = double.tryParse(_cantidadController.text) ?? 0;
    cantidad++;
    if (_esNumerado) {
      if (cantidad < productoEnVenta!.numerados.length) {
        // tengo que marcar el siguiente numerado en la BD como reservado
        int idx = (cantidad - 1).toInt();
        productoEnVenta!.numerados[idx].estado = "R";
        NumeradoModel item = await VentaProvider.ventaProvider.actualizarNumerado(productoEnVenta!.numerados[idx]);
        // actaulizo el estado en mi lista de numerados asociado al producto
        productoEnVenta!.numerados[idx] = item;
        // se crea el registro asociado para la pieza
        VentaDetallePiezaModel piezaModel = new VentaDetallePiezaModel(
            detalleVentaId: widget.actualVentaDetalle != null ? widget.actualVentaDetalle!.id : -1, inventarioId: item.id, peso: item.peso);
        // se agrega a la lista de numerados en la venta.
        numeradosEnVenta.add(piezaModel);
        setState(() {
          _pesoTotal += productoEnVenta!.numerados[idx].peso;
        });
      }
    }
    _cantidadController.text = cantidad.toString();
    setState(() {
      _excedeStock = cantidad > _stockDisponible;
    });

    _recalcularTotal();
  }

  void _decrementarCantidad() async {
    double cantidad = double.tryParse(_cantidadController.text) ?? 0;
    if (cantidad >= 1) {
      cantidad--;
      _cantidadController.text = cantidad.toString();
      if (_esNumerado) {
        if (cantidad < productoEnVenta!.numerados.length) {
          int idx = (cantidad).toInt();
          productoEnVenta!.numerados[idx].estado = "D";
          NumeradoModel item = await VentaProvider.ventaProvider.actualizarNumerado(productoEnVenta!.numerados[idx]);
          productoEnVenta!.numerados[idx] = item;
          numeradosEnVenta.removeAt(idx);
          setState(() {
            _pesoTotal -= productoEnVenta!.numerados[idx].peso;
          });
        }
      }
      setState(() {
        _excedeStock = cantidad > _stockDisponible;
      });
      _recalcularTotal();
    }
  }

  void _incrementarDescuento() {
    double descuento = double.tryParse(_descuentoController.text) ?? 0;
    descuento++;
    _descuentoController.text = descuento.toString();
    _recalcularTotal();
  }

  void _decrementarDescuento() {
    double descuento = double.tryParse(_descuentoController.text) ?? 0;
    descuento--;
    if (descuento < 0) descuento = 0;
    _descuentoController.text = descuento.toString();
    _recalcularTotal();
  }

  Widget _buildResumenInferior() {
    String formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';
    String formatNumber(double value) => value.toStringAsFixed(2);

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildResumenRow(
              'Stock:',
              _estaCargandoStock ? 'Cargando...' : '${formatNumber(_stockDisponible)} ($_unidadProducto)',
              valueColor: _stockDisponible > 0 ? Colors.blueAccent : Colors.red,
            ),
            _buildResumenRow(
              'Precio Unitario:',
              formatCurrency(_precioUnitario),
            ),
            _buildResumenRow(
              'Descuento:',
              formatCurrency(_valorDescuento),
              valueColor: _valorDescuento > 0 ? Colors.orange[700]! : Colors.grey[700]!,
            ),
            _buildResumenRow(
              '% ILA asociado:',
              '${formatNumber(_porcentajeILA)}%',
            ),
            Divider(height: 24, thickness: 1),
            _buildResumenRow(
              'Total Item:',
              formatCurrency(_valorFinal),
              valueColor: Colors.green[700]!,
              isBold: true,
              fontSize: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenRow(String label, String value, {Color valueColor = Colors.black, bool isBold = false, double fontSize = 16}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: fontSize, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _buscarProducto() async {
    productoEnVenta = await AppNavigator.pushNamed(AppRoutes.productosSeleccion);
    /*
    productoEnVenta = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProductosPage(isForSelection: true)),
    );
     */

    if (productoEnVenta != null && productoEnVenta is ProductosModel) {
      _actualizarProductoSeleccionado(productoEnVenta);
      _cargarStockProducto(productoEnVenta!.articulo);
    }
  }

  Future<void> _cargarStockProducto(String codigo) async {
    setState(() => _estaCargandoStock = true);
    try {
      productoEnVenta = await _productosProvider.obtenerProducto(codigo);

      if (productoEnVenta != null) {
        _productosBloc.updatePorduct(productoEnVenta!);
        setState(() {
          if (_esNumerado) {
            _stockDisponible = productoEnVenta!.pieces;
          } else {
            _stockDisponible = productoEnVenta!.stock;
          }
          _unidadProducto = productoEnVenta!.unidad;
          _porcentajeILA = productoEnVenta!.porcila; // Usando 'porcila'
        });
      }
    } catch (e) {
      _mostrarError('Error al cargar stock: $e');
      setState(() => _stockDisponible = 0);
    } finally {
      setState(() => _estaCargandoStock = false);
    }
  }

  void _buscarProductoPorTermino(String termino) async {
    if (termino.isEmpty) return;

    final productoEncontrado = _productosBloc.searchProduct(termino);

    if (productoEncontrado != null) {
      _actualizarProductoSeleccionado(productoEncontrado);
      _cargarStockProducto(productoEncontrado.articulo);
    } else {
      _mostrarError('Producto no encontrado: $termino');
    }
  }

  void _actualizarProductoSeleccionado(dynamic producto) {
    setState(() {
      _productoId = producto.articulo;
      _productoController.text = producto.descripcion;
      _precioUnitario = producto.ventaneto;
      _esNumerado = producto.numbered;
      _pesoTotal = 0;

      _unidadProducto = producto.unidad;
      _porcentajeILA = producto.porcila;
      _stockDisponible = 0; // Se resetea
      _estaCargandoStock = true; // Se pone a cargar
      // al cambiar el código de producto se debe limpiar la lista de piezas asociadas que tiene el registro.
      numeradosEnVenta.clear();
      _recalcularTotal();
      FocusScope.of(context).requestFocus(_cantidadFocusNode);

    });
  }

  /// Recalcula el valor del descuento y el total final
  void _recalcularTotal() {
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    final descuento = double.tryParse(_descuentoController.text) ?? 0;
    final subtotal = cantidad * _precioUnitario;
    final descuentoMonto = subtotal * (descuento / 100);
    final total = subtotal - descuentoMonto;

    setState(() {
      _valorFinal = total;
      _valorDescuento = descuentoMonto;
    });
  }

  void _guardar() async {
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    final porcentajeDescuento = double.tryParse(_descuentoController.text) ?? 0;

    if (_productoId == null) {
      _mostrarError('Debes seleccionar un producto.');
      return;
    }
    if (cantidad <= 0) {
      _mostrarError('La cantidad debe ser mayor a cero.');
      return;
    }

    if (porcentajeDescuento < 0 || porcentajeDescuento >= 50) {
      _mostrarError('El descuento debe estar entre 0 y 50%.');
      return;
    }
    try {
      final codigoProducto = _productoId!;
      final producto = await _productosProvider.obtenerProducto(codigoProducto);
      if (producto == null) {
        _mostrarError('Error: No se pudo validar el producto.');
        return;
      }
      _porcentajeILA = producto.porcila;
      final unidad = producto.unidad;
      final precioUnitatio = producto.ventaneto;
      final subtotal = (_esNumerado ? _pesoTotal : cantidad) * precioUnitatio;
      final totalDescuento = subtotal * (porcentajeDescuento / 100);
      final total = subtotal - totalDescuento;

      _productosBloc.updatePorduct(producto);

      final stockReal = producto.stock;
      setState(() => _stockDisponible = stockReal);
      final ventaId = widget.actualVenta == null ? -1 : widget.actualVenta!.id;

      final porcIva = 19.0;
      final totalIva = total * porcIva / 100;
      final porcIla = producto.porcila;
      final totalIla = total * porcIla / 100;

      final detalle = VentaDetalleModel(
          id: widget.actualVentaDetalle == null ? -1 : widget.actualVentaDetalle!.id,
          ventaId: ventaId,
          idProducto: producto.articulo,
          nombreProducto: producto.descripcion,
          cantidad: cantidad,
          precioUnitario: _precioUnitario,
          porcentajeDescuento: porcentajeDescuento,
          porcentajeIva: _porcentajeIVA,
          porcentajeIla: _porcentajeILA,
          totalDescuento: totalDescuento,
          totalIva: totalIva,
          totalIla: totalIla,
          totalLinea: total,
          unidad: unidad,
          piezas: 0,
          // TODO me falta validar las piezas
          piezasDetalle: numeradosEnVenta.isEmpty ? [] : numeradosEnVenta);
      String json = ventaDetalleModelToJson(detalle);
      developer.log("Enviando a grabar detalle venta $json");
      final VentaModel ventaModel = await VentaProvider.ventaProvider.saveItemVenta(detalle);
      AppNavigator.pop( ventaModel);
    } catch (e, s) {
      showAlertDialog(context, s.toString(), Icons.error);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }
}
