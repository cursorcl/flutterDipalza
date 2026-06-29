import 'package:dio/dio.dart';
import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/configuracion_model.dart';
import 'package:dipalza_movil/src/model/position_model.dart';

import '../services/api_client.dart';

class ParametrosProvider {
  static final ParametrosProvider parametrosProvider = ParametrosProvider._();
  final _dio = ApiClient().dio;

  ParametrosProvider._() {}

  Future<List<ConfiguracionModel>> obtenerConfiguraciones() async {
    try {
      final response = await _dio.get('/configurationa');
      final List<dynamic> data = response.data;
      return data.map((json) => ConfiguracionModel.fromJson(json)).toList();
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError(
          'ParametrosProvider', 'obtenerConfiguraciones', error.toString()));
      return [];
    }
  }

  Future<void> registrarUbicacion(PositionModel position) async {
    try {
      await _dio.put(
        '/regsiter/position',
        data: positionModelToJson(position),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError(
          'ParametrosProvider', 'registrarUbicacion', error.toString()));
    }
  }
}
