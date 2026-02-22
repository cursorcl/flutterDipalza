import 'package:dipalza_movil/src/share/app.formatter.dart';
import 'package:flutter/material.dart';

import '../../model/venta_detalle_model.dart';

class VentaDetalleTile extends StatelessWidget {
  final VentaDetalleModel item;

  const VentaDetalleTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {


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
    String cantidadConPiezas = (AppFormatters.formatoCantidad.format(item.cantidad)  + ' ' + item.unidad.toLowerCase()).trim();
    if (item.piezas > 0) {
      cantidadConPiezas += ' (${item.piezas} pz)';
    }

    return Card(

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Valor unitario a la izquierda
                Text(
                  AppFormatters.formatoMoneda.format(item.precioUnitario),
                  style: estiloSubtitulo.copyWith(fontWeight: FontWeight.w500),
                ),

                // Total descuento a la derecha (solo si es > 0)
                if (item.totalDescuento > 0)
                  Text(
                    '- ${AppFormatters.formatoMoneda.format(item.totalDescuento)}',
                    style: estiloDescuento,
                  )
                else Text('- \$0',  style: estiloDescuento  )
                ,
              ],
            ),

            // Separador
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.formatoMoneda.format(item.totalLinea),
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