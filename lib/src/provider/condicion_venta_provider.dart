import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/condicion-model.dart';
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
      Uri url = Uri.http(prefs.urlServicio, '/sellconditions');
      DBLogProvider.db.nuevoLog( creaLogInfo('CondicionVentaProvider', 'obtenerListaCondicionVenta', 'Inicio'));
      print('URL CondicionVenta: ' + url.toString());

      final resp = await http.get(url, headers: <String, String>{HttpHeaders.authorizationHeader: prefs.token});
      if(resp.statusCode == 200){
        print(resp.body);
        return condicionVentasModelFromJson(resp.body);
      }
      return [];
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError('CondicionVentaProvider', 'obtenerListaProductos', error.toString()));
      return [];
    }
  }


}
