import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ProductosProvider {
  static final ProductosProvider productosProvider = ProductosProvider._();

  ProductosProvider._() {
    //
  }

  Future<List<ProductosModel>> obtenerListaProductos() async {
    try {
      final prefs = new PreferenciasUsuario();
      Uri url = Uri.http(prefs.urlServicio, '/products');
      DBLogProvider.db.nuevoLog(
          creaLogInfo('ProductosProvider', 'obtenerListaProductos', 'Inicio'));
      print('URL Productos: ' + url.toString());

      final resp = await http.get(url, headers: <String, String>{
        HttpHeaders.authorizationHeader: prefs.token
      });
      print(resp.body);
      return productosModelFromJson(resp.body);
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError(
          'ProductosProvider', 'obtenerListaProductos', error.toString()));
      return [];
    }
  }

  /**
   * Método que obtiene un producto con sus atributos.
   * code corresponde al código del producto buscado.
   */
  Future<ProductosModel> obtenerProducto(String code) async {
    try {
      final prefs = new PreferenciasUsuario();
      Uri url = Uri.http(prefs.urlServicio, '/product/code/' + code);
      DBLogProvider.db.nuevoLog(creaLogInfo('ProductosProvider', 'obtenerProducto', 'Inicio'));
      print('URL Productos: ' + url.toString());

      final resp = await http.get(url, headers: <String, String>{HttpHeaders.authorizationHeader: prefs.token});
      print(resp.body);

      return productoModelFromJson(resp.body);
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError('ProductosProvider', 'obtenerProducto', error.toString()));
      return null;
    }
  }
}
