
import 'dart:convert';

import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ClientesProvider {
  static final ClientesProvider clientesProvider = ClientesProvider._();

  ClientesProvider._() {
    //
  }

  Future<List<ClientesModel>> obtenerListaClientes(
      String codVendedor, String codRuta, BuildContext context) async {
    final prefs = new PreferenciasUsuario();


    Uri url = Uri.http(
        prefs.urlServicio, '/clients/seller/$codVendedor/route/$codRuta');

    final resp = await http.get(url, headers: <String, String>{
      HttpHeaders.authorizationHeader: prefs.token,
      'Accept-Charset': 'utf-8'
    });
    
    if (resp.statusCode == 200 || resp.statusCode == 202) {
      String responseBody = utf8.decode(resp.bodyBytes);
      return clientesModelFromJson(responseBody);
    } else if(resp.statusCode == 500){
      Navigator.of(context).pop();
      showAlert(context, 'Problemas con el servicio de clientes, cierre la App y vuelva a ingresar.', Icons.error);
    }

     return clientesModelFromJson('[]');
    
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
