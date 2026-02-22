import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/page/ventas/venta.item.detelle.view.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/app.formatter.dart';
import 'package:dipalza_movil/src/share/app.navigator.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../model/venta_detalle_model.dart';
import '../../widget/connectivity_banner.widget.dart';
import '../../widget/fondo.widget.dart';

class ListadoDetalleDeUltimaVentaPage extends StatefulWidget {
  final VentaModel? ventaModel;

  const ListadoDetalleDeUltimaVentaPage({Key? key, this.ventaModel}) : super(key: key);

  @override
  _ListadoDetalleDeUltimaVentaPageState createState() => _ListadoDetalleDeUltimaVentaPageState();
}

class _ListadoDetalleDeUltimaVentaPageState extends State<ListadoDetalleDeUltimaVentaPage> {
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
          leading: BackButton(
            onPressed: () {
              // Aquí pones tu ruta específica
              AppNavigator.pop();
            },
          ),
          backgroundColor: colorRojoBase(),
          title: Text(
            this._venta!.nombreCliente,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Stack(children: <Widget>[
          Positioned.fill(
            child: FondoWidget(),
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                this._createHeaderVenta(),
                Expanded(child: _creaListaVentasDetalle(context) // si hay ID → carga desde backend
                    ),
              ],
            ),
          )
        ]));
  }

  Widget _creaListaVentasDetalle(BuildContext context) {
    return FutureBuilder(
      future: VentaProvider.ventaProvider.obtenerListaVentasDetalle(this._venta!.id),
      builder: (BuildContext context, AsyncSnapshot<List<VentaDetalleModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return  Column(
              children: <Widget>[
                ConnectivityBanner(),
                Expanded(child: ListView(children: _ventasDetalleItems(context, snapshot.data!))),
              ],
            )
          ;
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
          // El hijo es tu widget original
          child: VentaDetalleTile(item: itemVenta),
        );
        // ---- FIN DE LA MODIFICACIÓN ----
        _listItem.add(slidableItem);
      });
    }
    return _listItem;
  }

  Widget _createHeaderVenta() {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Condicion de Venta',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Spacer(),
                Text(
                  this._venta!.nombreCondicionVenta,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
              SizedBox(
                height: 4,
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Descuento',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Spacer(),
                Text(
                  AppFormatters.formatoMoneda.format(this._venta!.totalDescuento),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
              SizedBox(
                height: 4,
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Total Neto',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Spacer(),
                Text(
                  AppFormatters.formatoMoneda.format(this._venta!.totalNeto),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
              SizedBox(
                height: 4,
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Fecha',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Spacer(),
                Text(
                  AppFormatters.formatoFecha.format(this._venta!.fecha),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
            ])));
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
}
