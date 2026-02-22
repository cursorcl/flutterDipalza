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
      /*
      final prefs = new PreferenciasUsuario();
      final token = prefs.access_token;
      Uri url = Uri.http(prefs.urlServicio, '/api/productos');
      final resp = await http.get(url, headers: {'Accept-Charset': 'utf-8', 'Authorization': 'Bearer $token',});
      return productosModelFromJson(resp.body);
       */

      final response = await _dio.get('/api/productos');
      final List<dynamic> data = response.data;
      return data.map((json) => ProductosModel.fromJson(json)).toList();
    } catch (error) {
      return [];
    }
  }

  // Método que obtiene un producto con sus atributos.
  // code corresponde al código del producto buscado.

  Future<ProductosModel?> obtenerProducto(String code) async {
    try {
      /*
      final prefs = new PreferenciasUsuario();
      final token = prefs.access_token;
      Uri url = Uri.http(prefs.urlServicio, '/api/productos/' + code);
      final resp = await http.get(url, headers: {'Accept-Charset': 'utf-8', 'Authorization': 'Bearer $token',});
      print(resp.body);
      print(productoModelFromJson(resp.body));
      return productoModelFromJson(resp.body);
       */

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
}
