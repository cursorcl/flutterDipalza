import 'package:dipalza_movil/src/model/respuesta_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class VenderdorProvider {
  Future<RespuestaModel> loginUsuario(String usuario, String password) async {
    final prefs = new PreferenciasUsuario();
    Codec<String, String> stringToBase64 = utf8.fuse(base64);

//  Uri.http("example.org", "/path", { "q" : "dart" });
    final url = Uri.http(prefs.urlServicio, '/login',
        {"user": usuario, "password": stringToBase64.encode(password)});

        print(url);
    http.Response resp;
    try {
      resp = await http.get(url).timeout(Duration(seconds: 15));
    } catch (error) {
      return RespuestaModel(
          status: 500,
          detalle: 'Error en la conexión del servicio de Autenticación.');
    }

    if (resp != null && resp.statusCode == 401) {
      return RespuestaModel(
          status: resp.statusCode,
          detalle: 'Las credenciales son incorrectas.');
    } else if (resp != null && resp.statusCode == 409) {
      return RespuestaModel(
          status: resp.statusCode,
          detalle: 'Usuario con actividad en otro dispositivo');
    } else if (resp != null && resp.statusCode == 402) {
      return RespuestaModel(
          status: resp.statusCode,
          detalle: 'La versión de prueba ha finalizado.');
    }

    return RespuestaModel(status: resp.statusCode, detalle: resp.body);
  }
}
