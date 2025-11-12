import 'dart:async';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:rxdart/rxdart.dart';

class ProductosVentaBloc {
  static final ProductosVentaBloc _singleton =
      new ProductosVentaBloc._internal();

  factory ProductosVentaBloc() {
    return _singleton;
  }

  ProductosVentaBloc._internal() {
    _productosVentaController.value = [];
  }

  final _productosVentaController = BehaviorSubject<List<ProductosModel>>();
  Stream<List<ProductosModel>> get productosStream =>
      _productosVentaController.stream;

  List<ProductosModel> get listaProductos => _productosVentaController.value;

  agregarProducto(ProductosModel producto) {
    _productosVentaController.value.add(producto);
  }

  eliminarProducto(ProductosModel producto) {
    _productosVentaController.value.remove(producto);
  }

  limpiarProductos() {
    _productosVentaController.value.clear();
  }

  List<ProductosModel> get listaVentaProductos =>
      _productosVentaController.value;

  dispose() {
    _productosVentaController.close();
  }
}
