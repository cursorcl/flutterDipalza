import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/ConduccionModel.dart';

import '../services/api_client.dart';

class ConduccionProvider {
  static final ConduccionProvider conduccionProvider = ConduccionProvider._();
  final _dio = ApiClient().dio;

  ConduccionProvider._() {}

  Future<List<ConduccionModel>> obtenerListaConduccion() async {
    try {
      final response = await _dio.get('/api/conduccion');
      final List<dynamic> data = response.data;
      return data.map((json) => ConduccionModel.fromJson(json)).toList();
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError(
          'ConduccionProvider', 'obtenerListaConduccion', error.toString()));
      return [];
    }
  }

  Future<ConduccionModel?> obtenerConduccionPorCodigo(String codigo) async {
    try {
      final response = await _dio.get('/api/conduccion/$codigo');
      if (response.statusCode == 200) {
        return ConduccionModel.fromJson(response.data);
      }
      return null;
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError('ConduccionProvider',
          'obtenerConduccionPorCodigo', error.toString()));
      return null;
    }
  }
}
