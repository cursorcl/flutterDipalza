import 'package:dipalza_movil/src/model/rutas_model.dart';

import '../services/api_client.dart';

class RutasProvider {
  static final RutasProvider rutasProvider = RutasProvider._();
  final _dio = ApiClient().dio;

  RutasProvider._() {
    //
  }

  Future<List<RutasModel>> obtenerListaRutas() async {
    try {
      /*
      final prefs = PreferenciasUsuario(); // supongo que guardas el token aquí
      final token = prefs.access_token;     // obtén tu accessToken guardado
      Uri url = Uri.http(prefs.urlServicio, '/api/rutas');

      final resp = await http.get(url,
        headers: {'Accept-Charset': 'utf-8', 'Authorization': 'Bearer $token',},);
      String responseBody = utf8.decode(resp.bodyBytes);
      return rutasModelFromJson(responseBody);
       */

      final response = await _dio.get('/api/rutas');
      final List<dynamic> data = response.data;
      return data.map((json) => RutasModel.fromJson(json)).toList();
    } catch (error) {
      return [];
    }
  }
}
