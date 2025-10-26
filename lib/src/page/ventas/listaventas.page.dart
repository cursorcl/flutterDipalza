import 'package:dipalza_movil/src/model/transmitir_model.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/page/ventas/venta.page.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/cliente.select.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../widget/connectivity_banner.widget.dart';
import '../../widget/fondo.widget.dart';
import 'listaventas.detalle.page.dart';

class ListaVentasPage extends StatefulWidget {
  const ListaVentasPage({Key? key}) : super(key: key);

  @override
  _ListaVentasPageState createState() => _ListaVentasPageState();
}

class _ListaVentasPageState extends State<ListaVentasPage> {
  int cantidadVentas = 0;


  @override
  Widget build(BuildContext context) {
    final _puedeTransmitir = cantidadVentas > 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: Container(
          child: Center(
            child: Text(
              'Ventas',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _puedeTransmitir ? _transmitirDialog : null,
                icon: const Icon(Icons.cloud_upload, size: 20),
                label: const Text('Facturar'),
                style: TextButton.styleFrom(
                  // Su AppBar es rojo; asegure contraste blanco
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
    ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Llama a la navegación sin datos para "Crear"
          _irAPaginaVenta(context, null);
        },
        child: const Icon(Icons.add),
        backgroundColor: colorRojoBase(), // Usa tu color
      ),
      body: _creaListaVentas(context),
    );
  }

  Widget _creaListaVentas(BuildContext context) {
    return FutureBuilder(
      future: VentaProvider.ventaProvider.obtenerListaVentas(),
      builder:
          (BuildContext context, AsyncSnapshot<List<VentaModel>> snapshot) {
        if (snapshot.hasData) {
          final nuevaCant = snapshot.data!.length;

          // Solo si cambió, actualiza el estado del padre post-frame
          if (nuevaCant != cantidadVentas) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => cantidadVentas = nuevaCant);
            });
          }
            return Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: FondoWidget(),
                  ),
                  Positioned.fill(

                      child:Column(
              children: <Widget>[
                // ¡Aquí está! Se mostrará en la parte superior de la pantalla.
                ConnectivityBanner(),
                Expanded(
                    child: ListView(

                        children: _ventasItems(context, snapshot.data!))),
              ],
            ))]);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  List<Widget> _ventasItems(BuildContext context, List<VentaModel> listaVenta) {
    final List<Widget> _listItem = [];
  if(listaVenta.length == 0){
    _listItem.add(_createEmptyCard());
  }
  else {
    listaVenta.forEach((itemVenta) {
      _listItem
        ..add(
            _createCard(itemVenta)
        );
    });
  }

    return _listItem;
  }

  Widget _createEmptyCard() {
    return  Card(

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
            Text('No hay ventas por confirmar!!',
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
  Widget _createCard(VentaModel itemVenta) {
    return Slidable(
      // Clave única para que Flutter maneje bien la lista
        key: ValueKey(itemVenta.id),

        // --- Acciones de la izquierda (o usa endActionPane para la derecha) ---
        endActionPane: ActionPane(
          motion: const StretchMotion(), // Animación
          children: [
            // --- BOTÓN ELIMINAR ---
            SlidableAction(
              onPressed: (context) {
                // Llama a un nuevo diálogo de confirmación
                _eliminarVentaDialog(context, itemVenta);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Eliminar',
            ),
            // --- BOTÓN MODIFICAR ---
            SlidableAction(
              onPressed: (context) {
                // Llama a la misma página de "Nueva Venta" pero con datos
                _irAPaginaVenta(context, itemVenta);
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Modificar',
            ),
          ],
        ),

        // --- TU CARD ORIGINAL (EL "HIJO" DEL SLIDABLE) ---
        child:   Card(
      child: ListTile(
        tileColor: Colors.grey[100],
        leading: CircleAvatar(
          radius: 15,
          child: Icon(Icons.insert_chart),
          backgroundColor: HexColor('#455a64'),
          foregroundColor: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(itemVenta.clienteNombre ?? '--',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                )),
            SizedBox(
              height: 2.0,
            ),
            Text(getFormatRut(itemVenta.clienteRut),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                )),
            SizedBox(
              height: 5.0,
            ),
          ],
        ),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Text(formatoFechaCorta().format(itemVenta.fecha)),
            Text(itemVenta.condicionVentaNombre),
            Expanded(child: Container()),
            Text(
                getValorModena(
                    itemVenta.total +
                        itemVenta.totalIla +
                        itemVenta.totalIva -
                        itemVenta.totalDescuento,
                    0),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ))
          ],
        ),
        trailing: IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListaVentasDetallePage(ventaId: itemVenta.id), // Pasando el ventaId
                ),
              );
            }),
      ),
    )
    );
  }


  void _irAPaginaVenta(BuildContext context, VentaModel? venta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Pasa la venta (o null) a la PaginaVenta
        builder: (context) => PaginaVenta(ventaParaEditar: venta),
      ),
    ).then((valor) {
      // --- 4. (Opcional) Refresca la lista cuando vuelvas ---
      // Si PaginaVenta devuelve 'true' (o cualquier valor)
      // significando que se guardó algo, refrescamos el FutureBuilder.
      if (valor == true) {
        setState(() {
          // Esto forzará al FutureBuilder a recargarse
        });
      }
    });
  }
  Future<void> _eliminarVentaDialog(BuildContext context, VentaModel venta) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que deseas eliminar la venta de "${venta.clienteNombre ?? 'Cliente'}"?'),
                const Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // --- AQUÍ VA TU LÓGICA DE BORRADO ---
                print('Eliminando venta ID: ${venta.id}');

                // 1. Llama a tu provider:
                // VentaProvider.ventaProvider.eliminarVenta(venta.id);

                // 2. Cierra el diálogo y refresca la lista
                Navigator.of(context).pop();
                setState(() {
                  // Refresca el FutureBuilder
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _transmitirDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return MyDialog(cantidadVentas: this.cantidadVentas);
      },
    );
  }


}

// ignore: must_be_immutable
class MyDialog extends StatefulWidget {
  int cantidadVentas;
  MyDialog({required this.cantidadVentas});

  @override
  _MyDialogState createState() => new _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Center(
        child: Text(
          'Transmitir Ventas',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      content: SingleChildScrollView(
        child: _loading
            ? _loadingProcess()
            : ListBody(
                children: <Widget>[
                  Text(
                    'Se facturarán ${widget.cantidadVentas} ventas.',
                    textAlign: TextAlign.justify,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 30.0, left: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          width: 115.0,
                          child: ElevatedButton(
                            child: Container(
                              child: Text('Cancelar'),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              backgroundColor: Colors.grey,
                              elevation: 0.0,
                              textStyle: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Container(
                          width: 115.0,
                          child: ElevatedButton(
                            child: Container(
                              child: Text('Transmitir'),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              backgroundColor: Colors.green,
                              elevation: 0.0,
                              textStyle: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              setState(() {
                                _loading = true;
                                _callServiceTransmit(context);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  void _callServiceTransmit(BuildContext context) async {
    final prefs = new PreferenciasUsuario();
    bool resp = await VentaProvider.ventaProvider
        .transmitirVentas(context, new TransmitirModel(codigo: prefs.vendedor));
    Navigator.of(context).pop();
    if (resp) {
      showAlert(context, 'Transmisión de Ventas realizada con exito.',
          Icons.check_circle_outline);
    } else {
      showAlert(
          context, 'No se realizo la Transmisión de las Ventas', Icons.error);
    }
    setState(() {});
  }

  _loadingProcess() {
    return ListBody(children: <Widget>[
      Container(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(colorRojoBase()),
          ),
        ),
        height: 50.0,
      ),
      SizedBox(
        height: 10.0,
      ),
      Container(
        child: Center(
          child: Text('Procesando ...', textAlign: TextAlign.justify),
        ),
      )
    ]);
  }
}
