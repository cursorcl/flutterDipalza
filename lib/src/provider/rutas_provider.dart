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
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/routes');
    final resp = await http.get(url, headers: <String, String>{
      HttpHeaders.authorizationHeader: prefs.token
    });
    print(resp.body);
    return rutasModelFromJson(resp.body);
  }
}
