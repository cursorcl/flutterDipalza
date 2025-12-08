import 'dart:async';
import 'package:dipalza_movil/src/model/venta_detalle_model.dart';
import 'package:rxdart/rxdart.dart';

class VentaDetalleBloc {
  static final VentaDetalleBloc _singleton =
      new VentaDetalleBloc._internal();

  factory VentaDetalleBloc() {
    return _singleton;
  }

  VentaDetalleBloc._internal() {
    _ventaDetalleController.value = [];
  }

  final _ventaDetalleController = BehaviorSubject<List<VentaDetalleModel>>();
  Stream<List<VentaDetalleModel>> get productosStream =>
      _ventaDetalleController.stream;

  List<VentaDetalleModel> get listaVentaDetalles => _ventaDetalleController.value;

  agregarVentaDetalle(VentaDetalleModel producto) {
    _ventaDetalleController.value.add(producto);
  }

  eliminarVentaDetalle(VentaDetalleModel producto) {
    _ventaDetalleController.value.remove(producto);
  }

  limpiarVentaDetalles() {
    _ventaDetalleController.value.clear();
  }

  List<VentaDetalleModel> get listaVentaProductos =>
      _ventaDetalleController.value;

  dispose() {
    _ventaDetalleController.close();
  }
}
