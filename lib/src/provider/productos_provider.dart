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
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/products');
    final resp = await http.get(url, headers: <String, String>{
      HttpHeaders.authorizationHeader: prefs.token
    });
  print(resp.body);
    return productosModelFromJson(resp.body);
  }
}
