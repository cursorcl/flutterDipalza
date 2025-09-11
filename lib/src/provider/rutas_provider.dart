import 'dart:convert';

import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/rutas_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class RutasProvider {
  static final RutasProvider rutasProvider = RutasProvider._();

  RutasProvider._() {
    //
  }

  Future<List<RutasModel>> obtenerListaRutas() async {
    try {
      final prefs = PreferenciasUsuario(); // supongo que guardas el token aquí
      final token = prefs.token;     // obtén tu accessToken guardado
      Uri url = Uri.http(prefs.urlServicio, '/api/rutas');

      final resp = await http.get(url,
        headers: {'Accept-Charset': 'utf-8', 'Authorization': 'Bearer $token',},);
      String responseBody = utf8.decode(resp.bodyBytes);
      return rutasModelFromJson(responseBody);
    } catch (error) {
      return [];
    }
  }
}
