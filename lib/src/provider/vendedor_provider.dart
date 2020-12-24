import 'package:dipalza_movil/src/model/login.model.dart';
import 'package:dipalza_movil/src/model/respuesta_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class VenderdorProvider {
  Future<RespuestaModel> loginUsuario(String usuario, String password) async {
    final prefs = new PreferenciasUsuario();
    Codec<String, String> stringToBase64 = utf8.fuse(base64);

    final url = Uri.http(prefs.urlServicio, '/login');
    print(url);
    final login = LoginModel();
    print('>>>> Rut para Servicio: ' + getFormatRutToService(usuario));
    login.rut = getFormatRutToService(usuario);
    login.password = stringToBase64.encode(password);
    http.Response resp;
    try { // loginModelToJson
      resp = await http.post(url, body: loginModelToJson(login)).timeout(Duration(seconds: 15));
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
