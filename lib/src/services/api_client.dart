import 'package:dio/dio.dart';

import '../share/prefs_usuario.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  final pref = PreferenciasUsuario();


  // Singleton
  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: "http://" + this.pref.urlServicio,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Usamos QueuedInterceptorsWrapper en lugar de InterceptorsWrapper simple.
    // Esto asegura que las peticiones se procesen secuencialmente durante el refresco.
    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. Inyectar el token actual antes de cada petición
        final token =  pref.access_token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Si el error es 403 (Prohibido/Expirado)
        if (e.response?.statusCode == 403) {

          final bool renovado = await renovarToken();

          if (renovado) {
            final options = e.requestOptions;
            options.headers['Authorization'] = 'Bearer ${pref.access_token}';
            try {
              final response = await dio.fetch(options);
              return handler.resolve(response);
            } catch (err) {
              return handler.next(e);
            }
          }
        }
        return handler.next(e);
      },
    ));
  }
  /// Método para renovar el token directamente en el ApiClient
  Future<bool> renovarToken() async {
    try {
      final refreshToken = pref.refreshToken;
      if (refreshToken.isEmpty) return false;

      // Usamos una instancia local de Dio para evitar el interceptor
      // de esta misma clase y prevenir bucles infinitos.
      final dioRefresh = Dio();

      final resp = await dioRefresh.post(
        'http://${pref.urlServicio}/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(contentType: Headers.jsonContentType),
      );

      if (resp.statusCode == 200) {
        final nuevoAccessToken = resp.data['accessToken'];
        final nuevoRefreshToken = resp.data['refreshToken'];

        // Guardamos en las preferencias
        pref.access_token = nuevoAccessToken;
        if (nuevoRefreshToken != null) {
          pref.refreshToken = nuevoRefreshToken;
        }

        return true;
      }
      return false;
    } catch (e) {
      print("Error en renovación automática: $e");
      return false;
    }
  }
}