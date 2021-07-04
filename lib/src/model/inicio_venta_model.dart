import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/condicion-model.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';

class InicioVentaModel {
  final ClientesModel cliente;
  final CondicionVentaModel condicionVenta;
  final List<ProductosModel> listaVentaItem;

  InicioVentaModel({this.cliente, this.condicionVenta, this.listaVentaItem});
}