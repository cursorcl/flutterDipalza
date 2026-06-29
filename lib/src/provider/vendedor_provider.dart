import 'package:dio/dio.dart';
import 'package:dipalza_movil/src/model/login.model.dart';
import 'package:dipalza_movil/src/model/respuesta_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';

class VenderdorProvider {
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<RespuestaModel> loginUsuario(String usuario, String password) async {
    final prefs = PreferenciasUsuario();
    final login = LoginModel();
    // login.username = getFormatRutToService(usuario);
    login.username = usuario;
    login.password = password;

    try {
      final resp = await _dio.post(
        'http://${prefs.urlServicio}/auth/login',
        data: loginModelToJson(login),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      return RespuestaModel(
          status: resp.statusCode ?? 200, detalle: resp.data);
    } on DioException catch (e) {
      if (e.response == null) {
        return RespuestaModel(
          status: 500,
          detalle: {"error": "Error en la conexión del servicio de Autenticación."},
        );
      }

      switch (e.response!.statusCode) {
        case 401:
          return RespuestaModel(
            status: 401,
            detalle: {"error":"Las credenciales son incorrectas."}
          );
        case 409:
          return RespuestaModel(
            status: 409,
            detalle: {"error":"Usuario con actividad en otro dispositivo"},
          );
        case 402:
          return RespuestaModel(
            status: 402,
            detalle: {"error": "La versión de prueba ha finalizado."},
          );
        default:
          return RespuestaModel(
            status: e.response!.statusCode ?? 500,
            detalle: e.response?.data ?? {"error": "Error desconocido"},
          );
      }
    } catch (error) {
      return RespuestaModel(
        status: 500,
        detalle: {"error": "Error en la conexión del servicio de Autenticación."},
      );
    }
  }
}
