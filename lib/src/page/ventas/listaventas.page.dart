import 'package:dipalza_movil/src/model/inicio_venta_model.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/model/registro_venta_model.dart';
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
      body: _creaListaVentas(context),
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
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Container(
                    child: Text(
                      'Mantener presionada para Confirmar Venta.',
                      style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                    ),
                  ),
                ),
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
              onLongPress: () {
                print('CONFIRMAR VENTA');
                _confirmarDialog(itemVenta);
              },
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

  Future<void> _confirmarDialog(VentaModel venta) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Center(
            child: Text(
              'Confirmación de Venta',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Se realizará la confirmación de la venta para el cliente:',
                  textAlign: TextAlign.justify,
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(venta.razon,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('(' + getFormatRut(venta.rut) + ')',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(
                  height: 20.0,
                ),
                Text('Por un monto de:', textAlign: TextAlign.justify),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  getValorModena(
                      venta.neto +
                          venta.totalila +
                          venta.carne +
                          venta.iva -
                          venta.descuento,
                      0),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
               
                Container(
                  padding: EdgeInsets.only(top: 30.0, left: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: RaisedButton(
                          child: Container(
                            child: Text('Cancelar'),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          elevation: 0.0,
                          color: Colors.grey,
                          textColor: Colors.white,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Container(
                        width: 100.0,
                        child: RaisedButton(
                          child: Container(
                            child: Text('Confirmar'),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          elevation: 0.0,
                          color: Colors.green,
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              print('acepto confirmacion de venta');
                              _callServiceConfirm(
                                  context, venta);
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
      },
    );
  }

  void _callServiceConfirm(
      BuildContext context, VentaModel venta) async {
    final prefs = new PreferenciasUsuario();

    print('-------------');
    print(venta.rut);
    print(venta.codigo);
    print(prefs.vendedor);
    print(venta.fecha);
    print('-------------');

    bool resp = await VentaProvider.ventaProvider.confirmarVenta(
        new RegistroVentaModel(
            rut: venta.rut,
            codigo: venta.codigo,
            vendedor: prefs.vendedor,
            condicionVenta: '0',
            fecha: venta.fecha),
        context);

Navigator.of(context).pop();
    if (resp) {
      showAlert(context, 'Confirmación de Venta realizada con exito.',
          Icons.check_circle_outline);
    } else {
      showAlert(
          context, 'No se realizo la Confirmación de la Venta', Icons.error);
    }
    setState(() {});
    
  }
}
