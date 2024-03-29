import 'package:dipalza_movil/src/model/inicio_venta_model.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/model/transmitir_model.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/cliente.select.widget.dart';
import 'package:flutter/material.dart';

class ListaVentasPage extends StatefulWidget {
  const ListaVentasPage({Key key}) : super(key: key);

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
              'Lista de Ventas Diaria',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: _creaListaVentas(context),
      // floatingActionButton: creaBtnNuevaVenta(context),
      floatingActionButton: getFloatingActionButtons(context),
    );
  }

  Widget _creaListaVentas(BuildContext context) {
    return FutureBuilder(
      future: VentaProvider.ventaProvider.obtenerListaVentas(),
      builder:
          (BuildContext context, AsyncSnapshot<List<VentaModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null && snapshot.data.length > 0) {
            this.cantidadVentas = snapshot.data.length;
            return Column(
              children: <Widget>[
                Expanded(
                    child: ListView(
                        children: _ventasItems(context, snapshot.data))),
              ],
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
                  Text(
                      itemVenta.razon != null
                          ? itemVenta.razon
                          : 'Sin Información',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      )),
                  SizedBox(
                    height: 2.0,
                  ),
                  Text(getFormatRut(itemVenta.rut),
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
                  Text(formatoFechaCorta().format(itemVenta.fecha)),
                  Expanded(child: Container()),
                  Text(
                      getValorModena(
                          itemVenta.neto +
                              itemVenta.totalila +
                              itemVenta.carne +
                              itemVenta.iva -
                              itemVenta.descuento,
                          0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ))
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
            cliente: itemVenta.cliente, listaVentaItem: listaVentaItem, condicionVenta: itemVenta.condicionventa));
  }

  Widget creaBtnTramitar(BuildContext context) {
    return  Padding(
      
      padding: const EdgeInsets.only(left: 25.0, bottom: 0.0),
      child: FloatingActionButton.extended(
      onPressed: () {
        _transmitirDialog();
      },
      backgroundColor: HexColor('#ff7043'),
      tooltip: 'Transmitir Ventas',
      label: Text('Transmitir Ventas'),
    ));
  }

  Padding creaBtnNuevaVenta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, bottom: 0.0),
      child: ClientesSelectWidget(),
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

  getFloatingActionButtons(BuildContext context) {
    return Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: creaBtnTramitar(context),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: creaBtnNuevaVenta(context),
          ),
      ],
    );
  }



}

// ignore: must_be_immutable
class MyDialog extends StatefulWidget {
  int cantidadVentas;
  MyDialog({@required this.cantidadVentas});

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
                    'Se realizará la Transmisión de ${widget.cantidadVentas} ventas registradas.',
                    textAlign: TextAlign.justify,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 30.0, left: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          child: ElevatedButton(
                            child: Container(
                              child: Text('Cancelar'),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                              elevation: 0.0,
                              primary: Colors.grey,
                              textStyle: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Container(
                          width: 100.0,
                          child: ElevatedButton(
                            child: Container(
                              child: Text('Transmitir'),
                            ),
                            style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            elevation: 0.0,
                            primary: Colors.green,
                            textStyle: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              setState(() {
                                _loading = true;
                                print('acepto transmicion de venta');
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
