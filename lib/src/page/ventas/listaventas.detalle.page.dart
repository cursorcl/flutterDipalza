import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/page/ventas/venta.detelle.tile.dart';
import 'package:dipalza_movil/src/page/ventas/venta_edicion_item_detalle.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../model/venta_detalle_model.dart';
import '../../widget/connectivity_banner.widget.dart';
import '../../widget/fondo.widget.dart';

class ListaVentasDetallePage extends StatefulWidget {
  final VentaModel? ventaModel;
  final bool esEdicion;


  const ListaVentasDetallePage({Key? key, this.ventaModel, this.esEdicion = false}) : super(key: key);

  @override
  _ListaVentasPageState createState() => _ListaVentasPageState();
}

class _ListaVentasPageState extends State<ListaVentasDetallePage> {

  late VentaModel? _venta;
  int cantidadVentas = 0;
  List<VentaDetalleModel> ventas = [];

  @override
  void initState() {
    super.initState();
    _venta = widget.ventaModel; // copia inicial
  }

  @override
  Widget build(BuildContext context) {
    final _puedeTransmitir = cantidadVentas > 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: Container(
          child: Center(
            child: Text(
              this._venta != null    ? 'Venta #${this._venta?.id == -1 ? 'Nueva' : this._venta?.id}' : 'Nueva Venta',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      floatingActionButton:  widget.esEdicion ?
      FloatingActionButton(
          elevation: 10,
          tooltip: 'Agregar Item',
          child: const Icon(Icons.add),
          backgroundColor: colorRojoBase(),
          // Usa tu color
          onPressed: () {
            _inicializarNuevaVenta(context);
          })
          : null
    ,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. ENVUELVE EL CONTENIDO EN EXPANDED
            Expanded(
              child:  this._venta != null && this._venta?.id != -1
                  ? _creaListaVentasDetalle(context) // si hay ID → carga desde backend
                  : _buildNuevaVenta(context),
            ),


          ],
      ), // si no hay ID → muestra inicial vacío
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
      future: VentaProvider.ventaProvider.obtenerListaVentasDetalle(this._venta!.id),
      builder: (BuildContext context, AsyncSnapshot<List<VentaDetalleModel>> snapshot) {
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

  List<Widget> _ventasDetalleItems(BuildContext context, List<VentaDetalleModel> listaVenta) {
    final List<Widget> _listItem = [];
    if (listaVenta.length == 0) {
      _listItem.add(_createEmptyCard());
    } else {
      listaVenta.forEach((itemVenta) {
        final slidableItem = Slidable(
          key: ValueKey(itemVenta.id),
          endActionPane: widget.esEdicion ?  ActionPane(
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
          ) :  null,

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
    this.ventas = await VentaProvider.ventaProvider.obtenerListaVentasDetalle(id);
    setState(() {
      cantidadVentas = ventas.length;
    });
  }

  void _inicializarNuevaVenta(BuildContext context) {
    // Lógica para navegar a una pantalla de edición
    print('Nueva item de venta!');

    // Ejemplo de cómo navegarías (necesitarás una pantalla de edición)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VentaEdicionItemDetalle(ventaId: this._venta!.id,),
      ),
    ).then((ventaActualizada) {
      if (ventaActualizada != null) {
        setState(() {
          // haga lo que corresponda con el modelo devuelto
          this._venta = ventaActualizada;
        });
      }});
  }

  // --- Coloca esto dentro de la clase State de tu Widget ---

  void _modificarItem(BuildContext context, VentaDetalleModel item) {

    // Ejemplo de cómo navegarías (necesitarás una pantalla de edición)
    Navigator.push<VentaModel>(
      context,
      MaterialPageRoute(
        builder: (context) => VentaEdicionItemDetalle(actualVentaDetalle: item, ventaId: this._venta!.id,),
      ),
    ).then((ventaActualizada) {
      if (ventaActualizada != null) {
        setState(() {
          // haga lo que corresponda con el modelo devuelto
          this._venta = ventaActualizada;
        });
      }
    });


  }

  void _eliminarItem(BuildContext context, VentaDetalleModel item) {
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
