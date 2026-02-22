import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/app.navigator.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../share/app_routes.dart';
import '../../share/app_scaffold_key.dart';
import '../../widget/connectivity_banner.widget.dart';
import '../../widget/fondo.widget.dart';

class ListadeDeVentasPage extends StatefulWidget {
  const ListadeDeVentasPage({Key? key}) : super(key: key);

  @override
  _ListadoDeVentasPageState createState() => _ListadoDeVentasPageState();
}

class _ListadoDeVentasPageState extends State<ListadeDeVentasPage> {
  late Future<List<VentaModel>> _listaVentasFuture;
  int cantidadVentas = 0;

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  void _cargarVentas() {
    setState(() {
      _listaVentasFuture = VentaProvider.ventaProvider.obtenerListaVentas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            AppScaffoldKey.homeKey.currentState?.openDrawer();
            //Scaffold.of(context).openDrawer();

          },
        ),
        centerTitle: true,
        backgroundColor: colorRojoBase(),
        title: Text(
          'Ventas',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppNavigator.pushNamed(
            AppRoutes.nuevaVenta,
          ).then((valor) {
            if (valor == true) {
              setState(() {
                // Esto forzará al FutureBuilder a recargarse
              });
            }
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: colorRojoBase(), // Usa tu color
      ),
      body: _creaListaVentas(context),
    );
  }

  Widget _creaListaVentas(BuildContext context) {
    return FutureBuilder(
      future: _listaVentasFuture,
      builder: (BuildContext context, AsyncSnapshot<List<VentaModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 10),
                const Text('Ocurrió un error al cargar:', style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${snapshot.error}', // Esto nos dirá la verdad
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: _cargarVentas,
                  child: const Text("Reintentar"),
                )
              ],
            ),
          );
        } else
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
                ConnectivityBanner(),
                Expanded(child: ListView(children: _widgetListOfItemVenta(context, snapshot.data!))),
              ],
            ))
          ]);
        }
          else {
            return const Center(child: Text("Sin información disponible"));
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
                AppNavigator.pushNamed(
                  AppRoutes.modificarVenta,
                  arguments: {'ventaEnEdicion': itemVenta},
                ).then((valor) {
                  if (valor == true) {
                    setState(() {
                      // Esto forzará al FutureBuilder a recargarse
                    });
                  }
                });
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
                Text(itemVenta.nombreCliente,
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
                        fontWeight: FontWeight.normal, color: Colors.grey[700], fontSize: 13
                    )),
                SizedBox(
                  height: 5.0,
                ),
              ],
            ),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(itemVenta.nombreCondicionVenta,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.grey[700], fontSize: 10
                    )),
                Expanded(child: Container()),
                Text(getValorModena(itemVenta.total, 0),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ))
              ],
            ),
            trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  AppNavigator.pushNamed(AppRoutes.ventaDetalle, arguments: {'ventaModel': itemVenta, 'esEdicion': false});
                }),
          ),
        ));
  }

  void _goToVentaPage(BuildContext context, VentaModel? venta) {
    AppNavigator.pushNamed(
      AppRoutes.nuevaVenta,
      arguments: {'ventaEnEdicion': venta},
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
                AppNavigator.pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final result = await VentaProvider.ventaProvider.removeVenta(venta.id);
                if (result == false) {
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
                _cargarVentas();
              },
            ),
          ],
        );
      },
    );
  }
}
