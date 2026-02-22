import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/condicion_venta_model.dart';

import '../services/api_client.dart';

class CondicionVentaProvider {
  static final CondicionVentaProvider condicionVentaProvider = CondicionVentaProvider._();
  final _dio = ApiClient().dio;

  CondicionVentaProvider._() {
    //
  }

  Future<List<CondicionVentaModel>> obtenerListaCondicionVenta() async {
    try {
      /*
      final prefs = new PreferenciasUsuario();
      Uri url = Uri.http(prefs.urlServicio, '/api/condicionventa');
      final resp = await http.get(url,
          headers:{
            HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}',
            'Accept-Charset': 'utf-8'
      });
      if(resp.statusCode == 200){
        String responseBody = utf8.decode(resp.bodyBytes);
        return condicionVentasModelFromJson(responseBody);
      }
      return [];
     */

      final response = await _dio.get('/api/condicionventa');
      final List<dynamic> data = response.data;
      return data.map((json) => CondicionVentaModel.fromJson(json)).toList();
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError('CondicionVentaProvider', 'obtenerListaProductos', error.toString()));
      return [];
    }
  }
}
