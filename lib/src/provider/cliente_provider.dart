import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_client.dart';

class ClientesProvider {
  static final ClientesProvider clientesProvider = ClientesProvider._();
  final _dio = ApiClient().dio;

  ClientesProvider._() {
    //
  }

  Future<List<ClientesModel>> obtenerListaClientes(
      String codVendedor, String codRuta, BuildContext context) async {
    try {
      final response = await _dio.get('/api/clientes/ruta/$codRuta');
      final List<dynamic> data = response.data;
      return data.map((json) => ClientesModel.fromJson(json)).toList();
    } catch (error) {
      log(error.toString());
      return [];
    }
  }

  Future<List<ClientesModel>> obtenerListaClientesv2() async {
    final prefs = new PreferenciasUsuario();

    Uri url = Uri.http(prefs.urlServicio,
        '/clients/seller/${prefs.vendedor}/route/${prefs.ruta}');

    final resp = await http.get(url, headers: {
      HttpHeaders.authorizationHeader: prefs.access_token,
      'Accept-Charset': 'utf-8'
    });

    if (resp.statusCode == 200 || resp.statusCode == 202) {
      String responseBody = utf8.decode(resp.bodyBytes);
      return clientesModelFromJson(responseBody);
    }
    return clientesModelFromJson('[]');
  }

  Future<ClientesModel> obtenerClienteByRutCodigo(
      String rut, String codigo) async {
    final prefs = new PreferenciasUsuario();

    var params = prefs.urlServicio.split(":");

    final url = Uri(
      scheme: 'http',
      host: params[0],
      port: int.parse(params[1]),
      pathSegments: ['api', 'clientes', rut],
    );
    if (codigo.trim() != "") url.replace(queryParameters: {'codigo': codigo});

    final resp = await http.get(url, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}',
      'Accept-Charset': 'utf-8'
    });

    if (resp.statusCode == 200 || resp.statusCode == 202) {
      String responseBody = utf8.decode(resp.bodyBytes);
      return clienteModelFromJson(responseBody);
    }
    return clienteModelFromJson('{}');
  }
}
