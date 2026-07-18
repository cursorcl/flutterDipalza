import 'package:dio/dio.dart';
import 'package:dipalza_movil/src/model/rutas_model.dart';

import '../services/api_client.dart';

class VendedorRutaProvider {
  final _dio = ApiClient().dio;

  Future<List<RutasModel>> obtenerRutasAsignadas(
      String codigo, String tipo) async {
    final res = await _dio.get('/api/vendedores/$codigo/$tipo/rutas');
    return _rutasDesdeRespuesta(res, 'obtener');
  }

  Future<List<RutasModel>> guardarRutasAsignadas(
      String codigo, String tipo, List<String> codigosRuta) async {
    final res = await _dio.put('/api/vendedores/$codigo/$tipo/rutas',
        data: codigosRuta,
        options: Options(contentType: Headers.jsonContentType));
    return _rutasDesdeRespuesta(res, 'guardar');
  }

  List<RutasModel> _rutasDesdeRespuesta(Response res, String accion) {
    final data = res.data;
    if (data is! List) {
      // El caso que motivó esto: el servidor respondió sin la lista JSON
      // esperada (p.ej. content-type distinto de application/json), y Dio
      // entrega el cuerpo crudo. Antes esto fallaba con un TypeError
      // genérico ("String is not a subtype of List") sin decir qué llegó
      // realmente; ahora queda explícito para poder diagnosticarlo.
      throw Exception(
          "No se pudieron $accion las rutas del vendedor: se esperaba una "
          "lista y llegó '${data.runtimeType}' (status ${res.statusCode}, "
          "content-type '${res.headers.value('content-type')}'). "
          "Cuerpo recibido: $data");
    }
    return data.map((j) => RutasModel.fromJson(j)).toList();
  }
}
