import 'dart:convert';

import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/condicion_venta_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class CondicionVentaProvider {
  static final CondicionVentaProvider condicionVentaProvider = CondicionVentaProvider._();

  CondicionVentaProvider._() {
    //
  }

  Future<List<CondicionVentaModel>> obtenerListaCondicionVenta() async {
    try {
      final prefs = new PreferenciasUsuario();
      Uri url = Uri.http(prefs.urlServicio, '/api/condicionventa');
      final resp = await http.get(url,
          headers:{
            HttpHeaders.authorizationHeader: 'Bearer ${prefs.token}',
            'Accept-Charset': 'utf-8'
      });
      if(resp.statusCode == 200){
        String responseBody = utf8.decode(resp.bodyBytes);
        return condicionVentasModelFromJson(responseBody);
      }
      return [];
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError('CondicionVentaProvider', 'obtenerListaProductos', error.toString()));
      return [];
    }
  }


}
