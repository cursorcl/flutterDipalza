import 'package:dipalza_movil/src/model/inicio_venta_model.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/cliente.select.widget.dart';
import 'package:flutter/material.dart';

class ListaVentasPage extends StatefulWidget {
  const ListaVentasPage({Key key}) : super(key: key);

  @override
  _ListaVentasPageState createState() => _ListaVentasPageState();
}

class _ListaVentasPageState extends State<ListaVentasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: Container(
          child: Center(
            child: Text(
              'Lista de Ventas Diaria',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: <Widget>[
          Container()
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   tooltip: 'Buscar',
          //   onPressed: () {},
          // ),
        ],
      ),
      body: Stack(
        children: <Widget>[/**FondoWidget(),**/ _creaListaVentas(context)],
      ),
      floatingActionButton: creaBtnNuevaVenta(context),
    );
  }

  Widget _creaListaVentas(BuildContext context) {
    return FutureBuilder(
      future: VentaProvider.ventaProvider.obtenerListaVentas(),
      builder:
          (BuildContext context, AsyncSnapshot<List<VentaModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null && snapshot.data.length > 0) {
            return ListView(
              children: _ventasItems(context, snapshot.data),
            );
          } else {
            return Center(
              child: Text('No Existen Ventas por Confirmar.'),
            );
          }
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

    listaVenta.forEach((itemVenta) {
      _listItem
        ..add(
          Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 20,
                child: Icon(Icons.insert_chart),
                backgroundColor: HexColor('#455a64'),
                foregroundColor: Colors.white,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(itemVenta.razon != null ? itemVenta.razon : 'Sin Información', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, )),
                  SizedBox(height: 2.0,),
                  Text(getFormatRut(itemVenta.rut), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0, )),
                  SizedBox(height: 5.0,),
                ],
              ),
              subtitle: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(formatoFechaCorta().format(itemVenta.fecha)),
                  Expanded(child: Container()),
                  Text(getValorModena(
                      itemVenta.neto +
                          itemVenta.totalila +
                          itemVenta.carne +
                          itemVenta.iva -
                          itemVenta.descuento,
                      0), style: TextStyle(fontWeight: FontWeight.bold, ))
                ],
              ),
              trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    cargaDetalleVenta(context, itemVenta);
                  }),
            ),
          ),
        );
    });

    return _listItem;
  }

  cargaDetalleVenta(BuildContext context, VentaModel itemVenta) async {
    List<ProductosModel> listaVentaItem = await VentaProvider.ventaProvider
        .obtenerListaVentasItem(itemVenta.rut, itemVenta.codigo,
            itemVenta.fecha.millisecondsSinceEpoch);

    Navigator.pushNamed(context, 'venta',
        arguments: new InicioVentaModel(
            cliente: itemVenta.cliente, listaVentaItem: listaVentaItem));
  }

  Padding creaBtnNuevaVenta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, bottom: 0.0),
      child: ClientesSelectWidget(),
    );
  }
}
