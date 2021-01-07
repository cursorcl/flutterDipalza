import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';

class InicioVentaModel {
  final ClientesModel cliente;
  final List<ProductosModel> listaVentaItem;

  InicioVentaModel({this.cliente, this.listaVentaItem});
}