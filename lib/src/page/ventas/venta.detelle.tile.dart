import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/venta_detalle_model.dart';

class VentaDetalleTile extends StatelessWidget {
  final VentaDetalleModel item;

  const VentaDetalleTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Formateadores ---
    final formatoMoneda = NumberFormat(
      '\$ ###,##0', // <-- El patrón: Símbolo, espacio, y números
      'es_CL',       // <-- El locale para los separadores (punto de mil)
    );

    final formatoCantidad = NumberFormat(
      '###,##0.00', // <-- El patrón: Símbolo, espacio, y números
      'es_CL',       // <-- El locale para los separadores (punto de mil)
    );

    // --- Estilos de Texto ---
    const estiloNombreProd = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    final estiloTotal = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Theme.of(context).colorScheme.primary,
    );
    final estiloDescuento = TextStyle(
      color: Colors.red[700],
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );
    final estiloNormal = TextStyle(
      fontSize: 15,
      color: Colors.grey[800],
    );
    final estiloSubtitulo = TextStyle(
      fontSize: 14,
      color: Colors.grey[700],
    );

    // --- Lógica de Strings ---
    // 1. Crear el string de cantidad + piezas
    String cantidadConPiezas = (formatoCantidad.format(item.cantidad)  + ' ' + item.unidad.toLowerCase()).trim();
    if (item.piezas > 0) {
      cantidadConPiezas += ' (${item.piezas} pz)';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- LÍNEA 1: Nombre Producto | Cantidad ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expanded hace que el nombre ocupe el espacio
                Expanded(
                  child: Text(
                    item.nombreProducto,
                    style: estiloNombreProd,
                    maxLines: 2, // Por si el nombre es muy largo
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Un espacio pequeño
                const SizedBox(width: 10),
                // La cantidad se alinea a la derecha
                Text(
                  cantidadConPiezas,
                  style: estiloNormal,
                  textAlign: TextAlign.right,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // --- LÍNEA 2: Valor Unitario | Total Descuento ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Valor unitario a la izquierda
                Text(
                  formatoMoneda.format(item.precioUnitario),
                  style: estiloSubtitulo.copyWith(fontWeight: FontWeight.w500),
                ),

                // Total descuento a la derecha (solo si es > 0)
                if (item.totalDescuento > 0)
                  Text(
                    '- ${formatoMoneda.format(item.totalDescuento)}',
                    style: estiloDescuento,
                  )
                else Text('- \$0',  style: estiloDescuento  )
                ,
              ],
            ),

            // Separador
            const Divider(height: 16),

            // --- LÍNEA 3: Total Línea ---
            // Alineado a la derecha
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formatoMoneda.format(item.totalLinea),
                  style: estiloTotal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}