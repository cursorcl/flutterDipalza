import 'dart:developer';

import 'package:dipalza_movil/src/model/producto_model.dart';

import '../services/api_client.dart';

class ProductosProvider {
  static final ProductosProvider productosProvider = ProductosProvider._();
  final _dio = ApiClient().dio;

  ProductosProvider._() {
    //
  }

  Future<List<ProductosModel>> obtenerListaProductos() async {
    try {
      final response = await _dio.get('/api/productos');
      final List<dynamic> data = response.data;
      return data.map((json) => ProductosModel.fromJson(json)).toList();
    } catch (error) {
      log('Error al ejecutar obtenerListaProductos',
          name: 'ProductosProvider', error: error);
      rethrow;
    }
  }

  // Método que obtiene un producto con sus atributos.
  // code corresponde al código del producto buscado.

  Future<ProductosModel?> obtenerProducto(String code) async {
    try {
      final response = await _dio.get('/api/productos/' + code);
      log('Response data: ${response.data}', name: 'ProductosProvider');
      final Map<String, dynamic> data = response.data;
      return ProductosModel.fromJson(data);
    } catch (error) {
      log('Error al ejecutar obtenerProducto',
          name: 'ProductosProvider', error: error);
      return null;
    }
  }

  Future<double> obtenerPesoPromedioProducto(String code) async {
    try {
      final response = await _dio.get('/api/numerados/pesopromedio/$code');
      log('Response data: ${response.data}', name: 'ProductosProvider');

      if(response.data == null) return 0;

      if(response.data is num)
        return (response.data as num).toDouble();

      return 0;
    } catch (error) {
      log('Error al ejecutar obtenerProducto',
          name: 'ProductosProvider', error: error);
      return 0;
    }
  }
}
