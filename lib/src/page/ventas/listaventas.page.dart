import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/page/ventas/venta.page.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
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
),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _goToVentaPage(context, null);
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
      builder: (BuildContext context, AsyncSnapshot<List<VentaModel>> snapshot) {
        if (snapshot.hasData) {
          final nuevaCant = snapshot.data!.length;
          // Solo si cambió, actualiza el estado del padre post-frame
          if (nuevaCant != cantidadVentas) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => cantidadVentas = nuevaCant);
            });
          }
          return Stack(children: <Widget>[
            Positioned.fill(
              child: FondoWidget(),
            ),
            Positioned.fill(
                child: Column(
              children: <Widget>[
                // ¡Aquí está! Se mostrará en la parte superior de la pantalla.
                ConnectivityBanner(),
                Expanded(child: ListView(children: _widgetListOfItemVenta(context, snapshot.data!))),
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

  List<Widget> _widgetListOfItemVenta(BuildContext context, List<VentaModel> listaVenta) {
    final List<Widget> _listItem = [];
    if (listaVenta.length == 0) {
      _listItem.add(_widgetEmptyItem());
    } else {
      listaVenta.forEach((itemVenta) {
        _listItem..add(_widgetItemOfVenta(itemVenta));
      });
    }

    return _listItem;
  }

  Widget _widgetEmptyItem() {
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
            Text('No hay ventas!!',
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

  Widget _widgetItemOfVenta(VentaModel itemVenta) {
    return Slidable(
        key: ValueKey(itemVenta.id),
        endActionPane: ActionPane(
          motion: const StretchMotion(), // Animación
          children: [
            SlidableAction(
              onPressed: (context) {
                _showDialogRemoveItemVenta(context, itemVenta);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Eliminar',
            ),
            SlidableAction(
              onPressed: (context) {
                _goToVentaPage(context, itemVenta);
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Modificar',
            ),
          ],
        ),

        child: Card(
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
                Text(itemVenta.nombreCliente ?? '--',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    )),
                SizedBox(
                  height: 2.0,
                ),
                Text(getFormatRut(itemVenta.rutCliente),
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
                Text(itemVenta.nombreCondicionVenta),
                Expanded(child: Container()),
                Text(getValorModena(itemVenta.total + itemVenta.totalIla + itemVenta.totalIva - itemVenta.totalDescuento, 0),
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
                      builder: (context) => ListaVentasDetallePage(ventaModel: itemVenta, esEdicion: false),
                    ),
                  );
                }),
          ),
        ));
  }

  void _goToVentaPage(BuildContext context, VentaModel? venta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaginaVenta(ventaEnEdicion: venta),
      ),
    ).then((valor) {
      if (valor == true) {
        setState(() {
          // Esto forzará al FutureBuilder a recargarse
        });
      }
    });
  }

  Future<void> _showDialogRemoveItemVenta(BuildContext context, VentaModel venta) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que deseas eliminar la venta de "${venta.nombreCliente ?? 'Cliente'}"?'),
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
                final result = VentaProvider.ventaProvider.removeVenta(venta.id);
                if(result == false)
                  {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(child: Text("No se ha podido eliminar la venta!!", style: TextStyle(color: Colors.white))),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  }


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

}

