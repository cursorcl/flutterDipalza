import 'dart:developer' as developer;

import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart';
import 'package:flutter/material.dart';

// Asumiendo que esta es la ruta a tu BLoC
import '../../bloc/productos_bloc.dart';
import '../../model/producto_model.dart';
import '../../model/venta_detalle_model.dart';
import '../../provider/productos_provider.dart';
import '../producto/productos.page.dart';

class VentaEdicionItemDetalle extends StatefulWidget {
  final VentaDetalleModel? actualVentaDetalle; // si viene nulo, es nuevo
  final int? ventaId;

  const VentaEdicionItemDetalle({Key? key, this.actualVentaDetalle, this.ventaId}) : super(key: key);

  @override
  _VentaEdicionItemDetalleState createState() => _VentaEdicionItemDetalleState();
}

class _VentaEdicionItemDetalleState extends State<VentaEdicionItemDetalle> {
  final ProductosProvider _productosProvider = ProductosProvider.productosProvider;
  final ProductsBloc _productosBloc = ProductsBloc();

  // ---

  // Controllers
  late TextEditingController _productoController;
  late TextEditingController _cantidadController;
  late TextEditingController _descuentoController;

  // late TextEditingController _stockController; // (No se usaba, la he eliminado)

  // Focus Nodes (Añadido _productoFocusNode)
  late FocusNode _productoFocusNode;
  late FocusNode _cantidadFocusNode;
  late FocusNode _descuentoFocusNode;
  late FocusNode _guardarFocusNode;

  // Estado del BLoC
  bool _isBlocReady = false;

  // Estado del Producto
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

  @override
  void initState() {
    super.initState();
    // 1. LLAMA A LA CONFIGURACIÓN ASÍNCRONA (para evitar error ValueStream)
    _setupPagina();
  }

  /// Configuración asíncrona de la página
  Future<void> _setupPagina() async {
    // 2. ESPERA A QUE EL BLOC ESTÉ LISTO
    //    (Requiere 'initialLoadDone' en tu ProductsBloc)
    await _productosBloc.initialLoadDone;

    final pref = PreferenciasUsuario();
    final d = widget.actualVentaDetalle;

    // 3. INICIALIZA FOCUS NODES
    _productoFocusNode = FocusNode();
    _cantidadFocusNode = FocusNode();
    _descuentoFocusNode = FocusNode();
    _guardarFocusNode = FocusNode();

    // 4. INICIALIZA CONTROLLERS
    _cantidadController = TextEditingController(text: d?.cantidad.toString() ?? '1'); // '1' por defecto
    _descuentoController = TextEditingController(text: d?.totalDescuento.toString() ?? '0'); // '0' por defecto

    // 5. LÓGICA DE CARGA DE PRODUCTO (Modo Edición)
    if (d != null) {
      final String claveBusqueda = d.idProducto;

      // 6. USA TU MÉTODO 'searchProduct'
      final productoCache = _productosBloc.searchProduct(claveBusqueda);

      if (productoCache != null) {
        _productoId = productoCache.articulo;
        _productoController = TextEditingController(text: productoCache.descripcion);
        _precioUnitario = productoCache.ventaneto;
        _esNumerado = productoCache.numbered;
        _unidadProducto = productoCache.unidad;
        _porcentajeILA = productoCache.porcila;

        _cargarStockProducto(productoCache.articulo);
      } else {
        _productoController = TextEditingController(text: d.nombreProducto);
        _precioUnitario = d.precioUnitario;
        _esNumerado = d.piezas > 0;
      }
      _porcentajeIVA = d.porcentajeIva;
    } else {
      // Modo Nuevo
      _productoController = TextEditingController(text: '');
      _porcentajeIVA = pref.iva;
    }

    // 7. AÑADE LISTENERS PARA "SELECCIONAR TODO"
    _addSelectAllListener(_productoFocusNode, _productoController);
    _addSelectAllListener(_cantidadFocusNode, _cantidadController);
    _addSelectAllListener(_descuentoFocusNode, _descuentoController);

    _recalcularTotal();

    // 8. AVISA A LA UI QUE PUEDE DIBUJARSE
    setState(() {
      _isBlocReady = true;
    });
  }

  /// Helper para añadir listener de "Seleccionar Todo"
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
    // MUESTRA LOADER MIENTRAS EL BLOC NO ESTÉ LISTO
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
    final bool isDecrementDisabled = cantidadActual <= 1;
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
            // --- 1. WIDGET DE AUTOCOMPLETE PARA PRODUCTO ---
            Autocomplete<ProductosModel>(
              // Función que construye las opciones
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

              // Cómo construir el TextField
              fieldViewBuilder:
                  (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                // Sincroniza el controller de Autocomplete con el nuestro
                _productoController = fieldTextEditingController;
                _productoFocusNode = fieldFocusNode;
                // Vuelve a añadir el listener "Seleccionar Todo"
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

              // Personalización de la lista de opciones
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
            ),
            const SizedBox(height: 16),

            // --- 2. SPINNER DE CANTIDAD ---
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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

            // --- 3. CAMPO DE DESCUENTO (con seleccionar todo) ---
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
            // --- BOTÓN GUARDAR ---
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

  /// MÉTODOS PARA EL SPINNER
  void _incrementarCantidad() {
    double cantidad = double.tryParse(_cantidadController.text) ?? 0;
    cantidad++;
    _cantidadController.text = cantidad.toString();
    _recalcularTotal();
  }

  void _decrementarCantidad() {
    double cantidad = double.tryParse(_cantidadController.text) ?? 0;
    if (cantidad > 1) {
      // No permite bajar de 1
      cantidad--;
      _cantidadController.text = cantidad.toString();
      _recalcularTotal();
    }
  }

  /// MÉTODOS PARA EL SPINNER
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

  /// Construye el Card de resumen en la parte inferior
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

  /// Widget helper para las filas del resumen
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
    final productoSeleccionado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductosPage(isForSelection: true)),
    );

    if (productoSeleccionado != null && productoSeleccionado is ProductosModel) {
      _actualizarProductoSeleccionado(productoSeleccionado);
      _cargarStockProducto(productoSeleccionado.articulo);
    }
  }

  Future<void> _cargarStockProducto(String codigo) async {
    setState(() => _estaCargandoStock = true);
    try {
      final productoFresco = await _productosProvider.obtenerProducto(codigo);

      if (productoFresco != null) {
        // USA TU MÉTODO 'updatePorduct'
        _productosBloc.updatePorduct(productoFresco);

        // Faltaba actualizar el estado para mostrar el stock
        setState(() {
          _stockDisponible = productoFresco.stock;
          _unidadProducto = productoFresco.unidad;
          _porcentajeILA = productoFresco.porcila; // Usando 'porcila'
        });
      }
    } catch (e) {
      _mostrarError('Error al cargar stock: $e');
      setState(() => _stockDisponible = 0);
    } finally {
      setState(() => _estaCargandoStock = false);
    }
  }

  /// Busca un producto por el término ingresado (código o nombre)
  void _buscarProductoPorTermino(String termino) async {
    if (termino.isEmpty) return;

    // USA TU MÉTODO 'searchProduct'
    final productoEncontrado = _productosBloc.searchProduct(termino);

    if (productoEncontrado != null) {
      _actualizarProductoSeleccionado(productoEncontrado);
      _cargarStockProducto(productoEncontrado.articulo);
    } else {
      _mostrarError('Producto no encontrado: $termino');
    }
  }

  /// Helper para actualizar el estado con un producto seleccionado
  void _actualizarProductoSeleccionado(dynamic producto) {
    setState(() {
      _productoId = producto.articulo;
      _productoController.text = producto.descripcion;
      _precioUnitario = producto.ventaneto;
      _esNumerado = producto.numbered; // Tu archivo usaba 'pieces > 0'
      _pesoTotal = 0;

      _unidadProducto = producto.unidad;
      _porcentajeILA = producto.porcila;
      _stockDisponible = 0; // Se resetea
      _estaCargandoStock = true; // Se pone a cargar
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
      final subtotal = cantidad * precioUnitatio;
      final totalDescuento = subtotal * (porcentajeDescuento / 100);
      final total = subtotal - totalDescuento;

      _productosBloc.updatePorduct(producto);

      final stockReal = producto.stock;
      setState(() => _stockDisponible = stockReal);
      final ventaId = widget.actualVentaDetalle == null ? widget.ventaId : widget.actualVentaDetalle!.ventaId;

      final porcIva = 19.0;
      final totalIva = total * porcIva / 100;
      final porcIla = producto.porcila;
      final totalIla = total * porcIla / 100;

      final detalle = VentaDetalleModel(
          id: widget.actualVentaDetalle == null ? -1 : widget.actualVentaDetalle!.id,
          ventaId: ventaId!,
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
          piezasDetalle: const [] // TODO me falta seleccionar las piezas
          );
      developer.log("Enviando a grabar detalle venta: $detalle");
      final VentaModel ventaModel = await VentaProvider.ventaProvider.saveItemVenta(detalle);
      Navigator.pop(context, ventaModel);
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
