
import 'dart:convert';

import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'dart:developer';

class ClientesProvider {
  static final ClientesProvider clientesProvider = ClientesProvider._();

  ClientesProvider._() {
    //
  }

  Future<List<ClientesModel>> obtenerListaClientes(
      String codVendedor, String codRuta, BuildContext context) async {
    try {
    final prefs = new PreferenciasUsuario();
    final token = prefs.token;
    Uri url = Uri.http(prefs.urlServicio, '/api/clientes/ruta/$codRuta');
    final resp = await http.get(url, headers: {'Accept-Charset': 'utf-8', 'Authorization': 'Bearer $token',});
    final body = clientesModelFromJson(resp.body);
    return body;
    } catch (error) {
      log(error.toString());
      return [];
    }
  }

  Future<List<ClientesModel>> obtenerListaClientesv2() async {
    final prefs = new PreferenciasUsuario();

    Uri url = Uri.http(
        prefs.urlServicio, '/clients/seller/${prefs.vendedor}/route/${prefs.ruta}');
        
    final resp = await http.get(url, headers: {
      HttpHeaders.authorizationHeader: prefs.token,
      'Accept-Charset': 'utf-8'
    });
    
    if (resp.statusCode == 200 || resp.statusCode == 202) {
      String responseBody = utf8.decode(resp.bodyBytes);
      return clientesModelFromJson(responseBody);
    }
     return clientesModelFromJson('[]');
    
  }

}
