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
      final prefs = new PreferenciasUsuario();
      Uri url = Uri.http(prefs.urlServicio, '/routes');
      DBLogProvider.db.nuevoLog(
          creaLogInfo('RutasProvider', 'obtenerListaRutas', 'Inicio'));
      print('URL RUTAS: ' + url.toString());

      final resp = await http.get(url, headers: <String, String>{
        HttpHeaders.authorizationHeader: prefs.token
      });
      DBLogProvider.db.nuevoLog(creaLogInfo('RutasProvider',
          'obtenerListaRutas', '[Status Code: ${resp.statusCode}]'));
      print(resp.body);
      return rutasModelFromJson(resp.body);
    } catch (error) {
      DBLogProvider.db.nuevoLog(
          creaLogError('RutasProvider', 'obtenerListaRutas', error.toString()));
      return [];
    }
  }
}
