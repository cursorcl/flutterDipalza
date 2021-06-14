import 'dart:async';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/provider/productos_provider.dart';
import 'package:rxdart/rxdart.dart';

class ProductosBloc {

  static final ProductosBloc _singleton = new ProductosBloc._internal();
  final _productosController = BehaviorSubject<List<ProductosModel>>();

  factory ProductosBloc() {
    return _singleton;
  }

  ProductosBloc._internal() {
    obtenerListaProductos();
  }

  
  Stream<List<ProductosModel>> get productosStream =>_productosController.stream;
  List<ProductosModel> get listaProductos => _productosController.value;

  obtenerListaProductos() async {
    _productosController.sink.add(await ProductosProvider.productosProvider.obtenerListaProductos());
  }

  dispose() {
    _productosController?.close();
  }
}
