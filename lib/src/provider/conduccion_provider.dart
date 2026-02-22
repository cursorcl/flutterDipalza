import 'dart:convert';
import 'dart:io';

import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/ConduccionModel.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:http/http.dart' as http;

import '../services/api_client.dart';

class ConduccionProvider {
  static final ConduccionProvider conduccionProvider = ConduccionProvider._();
  final _dio = ApiClient().dio;

  ConduccionProvider._() {
  }

  Future<List<ConduccionModel>> obtenerListaConduccion() async {
    try {
      /*
      final prefs = new PreferenciasUsuario();
      Uri url = Uri.http(prefs.urlServicio, '/api/conduccion');
      final resp = await http.get(url,
          headers:{
            HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}',
            'Accept-Charset': 'utf-8'
          });
      if(resp.statusCode == 200){
        String responseBody = utf8.decode(resp.bodyBytes);
        return conduccionesModelFromJson(responseBody);
      }
      return [];
       */

      final response = await _dio.get('/api/conduccion');
      final List<dynamic> data = response.data;
      return data.map((json) => ConduccionModel.fromJson(json)).toList();

    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError('ConduccionProvider', 'obtenerListaConduccion', error.toString()));
      return [];
    }
  }

  Future<ConduccionModel?> obtenerConduccionPorCodigo(String codigo) async {
    final prefs = new PreferenciasUsuario();
    final token = prefs.access_token;

    try {
      final url = Uri.http(prefs.urlServicio, '/api/conduccion/$codigo');
      final resp = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Accept-Charset': 'utf-8'
      });
      if(resp.statusCode == 200){
        String responseBody = utf8.decode(resp.bodyBytes);
        return conduccionModelFromJson(responseBody);
      }
      return null;
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError('ConduccionProvider', 'obtenerListaConduccion', error.toString()));
      return null;
    }
  }

}
