
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/venta_detalle_item_model.dart';
import '../producto/productos.page.dart';

class VentaEdicionItemDetalle extends StatefulWidget {
  final VentaDetalleItemModel? item; // si viene nulo, es nuevo

  const VentaEdicionItemDetalle({Key? key, this.item}) : super(key: key);

  @override
  _VentaEdicionItemDetalleState createState() => _VentaEdicionItemDetalleState();
}

class _VentaEdicionItemDetalleState extends State<VentaEdicionItemDetalle> {
  late TextEditingController _productoController;
  late TextEditingController _cantidadController;
  late TextEditingController _descuentoController;

  double _precioUnitario = 0;
  double _valorFinal = 0;
  double _pesoTotal = 0;
  bool _esNumerado = false;

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _productoController = TextEditingController(text: d?.nombreProducto ?? '');
    _cantidadController = TextEditingController(text: d?.cantidad.toString() ?? '');
    _descuentoController = TextEditingController(text: d?.descuento.toString() ?? '');
    _precioUnitario = d?.precioUnitario ?? 0;
    _esNumerado = d != null ? (d!.piezas > 0) : false;
    _pesoTotal =  0;
    _recalcularTotal();
  }

  void _recalcularTotal() {
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    final descuento = double.tryParse(_descuentoController.text) ?? 0;
    final subtotal = cantidad * _precioUnitario;
    final total = subtotal * (1 - descuento / 100);
    setState(() => _valorFinal = total);
  }

  @override
  void dispose() {
    _productoController.dispose();
    _cantidadController.dispose();
    _descuentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Agregar producto' : 'Editar detalle'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- PRODUCTO ---
            TextField(
              controller: _productoController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Producto',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _buscarProducto,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- CANTIDAD ---
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad'),
              onChanged: (_) => _recalcularTotal(),
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

            // --- DESCUENTO ---
            TextField(
              controller: _descuentoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Descuento (%)'),
              onChanged: (_) => _recalcularTotal(),
            ),

            const SizedBox(height: 24),

            // --- VALORES CALCULADOS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Precio unitario: \$${_precioUnitario.toStringAsFixed(2)}'),
                Text('Total: \$${_valorFinal.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),

            const Spacer(),

            // --- BOTÓN GUARDAR ---
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Guardar'),
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buscarProducto() async {
    // Navega a la pantalla de productos
    final productoSeleccionado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductosPage(isForSelection : true)),
    );

    if (productoSeleccionado != null) {
      setState(() {
        _productoController.text = productoSeleccionado.descripcion;
        _precioUnitario = productoSeleccionado.ventaneto;
        _esNumerado = productoSeleccionado.pieces > 0;
        _pesoTotal = 0;
        _recalcularTotal();
      });
    }
  }

  void _guardar() {
    /*
    final detalle = VentaDetalleItemModel(
      productoId: widget.detalle?.productoId,
      descripcion: _productoController.text,
      cantidad: double.tryParse(_cantidadController.text) ?? 0,
      precioUnitario: _precioUnitario,
      descuento: double.tryParse(_descuentoController.text) ?? 0,
      esNumerado: _esNumerado,
      pesoTotal: _pesoTotal,
    );

    Navigator.pop(context, detalle); // ← retorna el detalle actualizado
    */
  }
}
