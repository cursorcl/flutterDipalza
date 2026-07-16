import 'package:dipalza_movil/src/model/rutas_model.dart';

import '../services/api_client.dart';

class VendedorRutaProvider {
  final _dio = ApiClient().dio;

  Future<List<RutasModel>> obtenerRutasAsignadas(
      String codigo, String tipo) async {
    final res = await _dio.get('/api/vendedores/$codigo/$tipo/rutas');
    final List<dynamic> data = res.data;
    return data.map((j) => RutasModel.fromJson(j)).toList();
  }

  Future<List<RutasModel>> guardarRutasAsignadas(
      String codigo, String tipo, List<String> codigosRuta) async {
    final res = await _dio.put('/api/vendedores/$codigo/$tipo/rutas',
        data: codigosRuta);
    final List<dynamic> data = res.data;
    return data.map((j) => RutasModel.fromJson(j)).toList();
  }
}
