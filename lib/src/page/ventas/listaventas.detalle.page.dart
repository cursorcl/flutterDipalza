import 'package:dipalza_movil/src/page/ventas/venta.detelle.tile.dart';
import 'package:dipalza_movil/src/page/ventas/venta_edicion_item_detalle.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../model/venta_detalle_item_model.dart';
import '../../widget/connectivity_banner.widget.dart';
import '../../widget/fondo.widget.dart';

class ListaVentasDetallePage extends StatefulWidget {
  final int? ventaId;

  const ListaVentasDetallePage({Key? key, this.ventaId}) : super(key: key);

  @override
  _ListaVentasPageState createState() => _ListaVentasPageState();
}

class _ListaVentasPageState extends State<ListaVentasDetallePage> {
  int cantidadVentas = 0;
  List<VentaDetalleItemModel> ventas = [];

  @override
  Widget build(BuildContext context) {
    final _puedeTransmitir = cantidadVentas > 0;
    final esEdicion = widget.ventaId != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: Container(
          child: Center(
            child: Text(
              esEdicion ? 'Detalle de Venta #${widget.ventaId}' : 'Nueva Venta',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: esEdicion
          ? _creaListaVentasDetalle(context)   // si hay ID → carga desde backend
          : _buildNuevaVenta(context),          // si no hay ID → muestra inicial vacío
    );
  }
  Widget _buildNuevaVenta(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: FondoWidget()),
        Positioned.fill(
          child: Column(
            children: [
              const ConnectivityBanner(),
              Expanded(
                child: ListView(
                  children: [
                    _createEmptyCard(),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Aún no se ha creado la venta.\nAgrega productos para iniciar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _creaListaVentasDetalle(BuildContext context) {
    return FutureBuilder(
      future: VentaProvider.ventaProvider.obtenerListaVentasDetalle(widget.ventaId!),
      builder: (BuildContext context, AsyncSnapshot<List<VentaDetalleItemModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final nuevaCant = snapshot.data!.length;

          return Stack(children: <Widget>[
            Positioned.fill(
              child: FondoWidget(),
            ),
            Positioned.fill(
                child: Column(
              children: <Widget>[
                ConnectivityBanner(),
                Expanded(child: ListView(children: _ventasDetalleItems(context, snapshot.data!))),
              ],
            ))
          ]);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  List<Widget> _ventasDetalleItems(BuildContext context, List<VentaDetalleItemModel> listaVenta) {
    final List<Widget> _listItem = [];
    if (listaVenta.length == 0) {
      _listItem.add(_createEmptyCard());
    } else {
      listaVenta.forEach((itemVenta) {
// ---- INICIO DE LA MODIFICACIÓN ----
        final slidableItem = Slidable(
          // Una clave única es buena para el rendimiento de la lista
          key: ValueKey(itemVenta.linea),

          // Acciones de la derecha (al deslizar de derecha a izquierda)
          endActionPane: ActionPane(
            motion: const StretchMotion(), // Un efecto visual
            children: [
              // --- BOTÓN ELIMINAR ---
              SlidableAction(
                onPressed: (context) {
                  // Llama a tu función de lógica
                  _eliminarItem(context, itemVenta);
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Eliminar',
              ),
              // --- BOTÓN MODIFICAR ---
              SlidableAction(
                onPressed: (context) {
                  // Llama a tu función de lógica
                  _modificarItem(context, itemVenta);
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Modificar',
              ),
            ],
          ),

          // El hijo es tu widget original
          child: VentaDetalleTile(item: itemVenta),
        );
        // ---- FIN DE LA MODIFICACIÓN ----
        _listItem.add(slidableItem);
      });
    }
    return _listItem;
  }
  Widget _createEmptyCard() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          child: Icon(Icons.insert_chart),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Sin productos agregados!!',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                )),
          ],
        ),
      ),
    );
  }


  void _cargarDatos(int id) async {
    // Ejemplo: llamada al backend o base local
    // final venta = await ventaService.getVenta(id);
    this.ventas  = await VentaProvider.ventaProvider.obtenerListaVentasDetalle(id);
    setState(() {
      cantidadVentas = ventas.length;
    });
  }

  void _inicializarNuevaVenta() {
    // Prepara una venta vacía o valores iniciales
    setState(() {
      this.ventas = [];
      cantidadVentas = 0;
    });
  }

  // --- Coloca esto dentro de la clase State de tu Widget ---

  void _modificarItem(BuildContext context, VentaDetalleItemModel item) {
    // Lógica para navegar a una pantalla de edición
    print('Modificar: ${item.nombreProducto}');

    // Ejemplo de cómo navegarías (necesitarás una pantalla de edición)
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VentaEdicionItemDetalle(item: item),
    ),
  );
  }

  void _eliminarItem(BuildContext context, VentaDetalleItemModel item) {
    // ¡MUY IMPORTANTE! Siempre pide confirmación antes de borrar.
    print('Eliminar: ${item.nombreProducto}');

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Seguro que quieres eliminar "${item.nombreProducto}"?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // --- AQUÍ VA TU LÓGICA DE BORRADO REAL ---
                // 1. Llama a tu BLoC, Provider o API para borrar el dato.
                // 2. Si tiene éxito, actualiza el estado (ej. llamando a setState
                //    o refrescando el FutureBuilder) para que la lista se repinte.

                print('Eliminando: ${item.nombreProducto}');

                Navigator.of(ctx).pop(); // Cierra el diálogo

                // Ejemplo simple si 'listaVenta' fuera una variable de estado:
                // setState(() => listaVenta.remove(item));
                // (En tu caso, con FutureBuilder, probablemente necesites
                // llamar al método que recarga el Future)
              },
            ),
          ],
        );
      },
    );
  }
}
