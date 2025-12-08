import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/page/home/home2.page.dart';
import 'package:dipalza_movil/src/page/ventas/venta.item.detelle.view.dart';
import 'package:dipalza_movil/src/page/ventas/venta.item.detalle.edicion.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/app_routes.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../model/venta_detalle_model.dart';
import '../../share/app.navigator.dart';
import '../../widget/connectivity_banner.widget.dart';
import '../../widget/fondo.widget.dart';

class ListadoDetalleDeUnaVentaPage extends StatefulWidget {
  final VentaModel? ventaModel;
  final bool esEdicion;


  const ListadoDetalleDeUnaVentaPage({Key? key, this.ventaModel, this.esEdicion = false}) : super(key: key);

  @override
  _ListaVentasPageState createState() => _ListaVentasPageState();
}

class _ListaVentasPageState extends State<ListadoDetalleDeUnaVentaPage> {

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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.esEdicion,
        leading: widget.esEdicion ? null : BackButton(
          onPressed: () {
            // Aquí pones tu ruta específica
            Navigator.pushNamed(context, '/listadoDeVentas');
          },
        ),
        backgroundColor: colorRojoBase(),
        title:  Text(
              this._venta != null    ? 'Venta #${this._venta?.id == -1 ? 'Nueva' : this._venta?.id}' : 'Nueva Venta',
              style: TextStyle(color: Colors.white),
            ),
        actions: !widget.esEdicion ? [] : [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: "Finalizar Venta",
            onPressed: _finalizarVenta,
          ),
        ],
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

  void _inicializarNuevaVenta(BuildContext context) {
    // Lógica para navegar a una pantalla de edición

    AppNavigator.pushNamed(AppRoutes.ventaItemEdicion, arguments : {
      'actualVenta' : this._venta
    }).then((ventaActualizada) {
      if (ventaActualizada != null) {
        setState(() {
          // haga lo que corresponda con el modelo devuelto
          this._venta = ventaActualizada as VentaModel?;
        });
      }});
/*    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VentaEdicionItemDetalle(actualVenta: this._venta,),
      ),
    ).then((ventaActualizada) {
      if (ventaActualizada != null) {
        setState(() {
          // haga lo que corresponda con el modelo devuelto
          this._venta = ventaActualizada;
        });
      }});*/
  }

  // --- Coloca esto dentro de la clase State de tu Widget ---

  void _modificarItem(BuildContext context, VentaDetalleModel item) {

    AppNavigator.pushNamed(AppRoutes.ventaItemEdicion,
      arguments: {
      'actualVentaDetalle' : item,
        'actualVenta' : this._venta
      }
    ).then((ventaActualizada) {
      if (ventaActualizada != null) {
        setState(() {
          // haga lo que corresponda con el modelo devuelto
          this._venta = ventaActualizada as VentaModel?;
        });
      }
    });

/*    Navigator.of(context).push<VentaModel>(
      MaterialPageRoute(
        builder: (context) => VentaEdicionItemDetalle(actualVentaDetalle: item, actualVenta: this._venta,),
      ),
    ).then((ventaActualizada) {
      if (ventaActualizada != null) {
        setState(() {
          // haga lo que corresponda con el modelo devuelto
          this._venta = ventaActualizada;
        });
      }
    });*/


  }
  void _finalizarVenta() {
    // Validar que exista la venta actual
    if (_venta == null) {
      return;
    }

    // Aquí podrías agregar validaciones adicionales:
    // - que la venta tenga al menos un producto
    // - que el total sea mayor que 0, etc.

    Navigator.of(context).pushNamed(
        'listadoDeVentas'
    );
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
