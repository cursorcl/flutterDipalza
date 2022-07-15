import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/configuracion_model.dart';
import 'package:dipalza_movil/src/model/position_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ParametrosProvider {
  static final ParametrosProvider parametrosProvider = ParametrosProvider._();

  ParametrosProvider._() {
    //
  }

  Future<List<ConfiguracionModel>> obtenerConfiguraciones() async {
    try {
      final prefs = new PreferenciasUsuario();
      Uri url = Uri.http(prefs.urlServicio, '/configuration');
      // DBLogProvider.db.nuevoLog(
      //     creaLogInfo('ParametrosProvider', 'obtenerConfiguraciones', 'Inicio'));
      print('URL Configuraciones: ' + url.toString());

      final resp = await http.get(url, headers: <String, String>{
        HttpHeaders.authorizationHeader: prefs.token
      });
      // DBLogProvider.db.nuevoLog(creaLogInfo('ParametrosProvider',
      //     'obtenerConfiguraciones', '[Status Code: ${resp.statusCode}]'));
      print(resp.body);
      return configuracionModelFromJson(resp.body);
    } catch (error) {
      DBLogProvider.db.nuevoLog(
          creaLogError('ParametrosProvider', 'obtenerConfiguraciones', error.toString()));
      return [];
    }
  }

  Future<void> registrarUbicacion(PositionModel position) async {
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/regsiter/position');
    print('URL Registrar Ubicacion: ' + url.toString());

    try {
      await http.put(url,
          body: positionModelToJson(position),
          headers: <String, String>{
            HttpHeaders.authorizationHeader: prefs.token,
            'Content-Type': 'application/json; charset=UTF-8',
          });
    } catch (error) {
      DBLogProvider.db.nuevoLog(
          creaLogError('ParametrosProvider', 'registrarUbicacion', error.toString()));
    }

  }

}
