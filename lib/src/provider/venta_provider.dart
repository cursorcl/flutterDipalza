import 'package:dipalza_movil/src/bloc/productos_venta_bloc.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/model/registro_item_model.dart';
import 'package:dipalza_movil/src/model/registro_item_resp_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class VentaProvider {
  static final VentaProvider ventaProvider = VentaProvider._();

  VentaProvider._() {
    //
  }

  Future<RegistroItemRespModel> registrarItem(
      RegistroItemModel registro, BuildContext context) async {
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/registeritem/');
    print('URL Registrar: ' + url.toString());

    http.Response resp;
    try {
      resp = await http.post(url,
          body: registroItemModelToJson(registro),
          headers: <String, String>{
            HttpHeaders.authorizationHeader: prefs.token
          });
    } catch (error) {
      Navigator.of(context).pop();
      showAlert(context, 'Problemas al agregar un Producto, Vuelva a intentar.',
          Icons.error);
    }

    print(resp.body);
    if (resp.statusCode == 200 || resp.statusCode == 202) {
      return registroItemRespModelFromJson(resp.body);
    } else if (resp.statusCode == 500) {
      Navigator.of(context).pop();
      showAlert(context, 'Problemas al agregar un Producto, Vuelva a intentar.',
          Icons.error);
    }

    return registroItemRespModelFromJson('{}');
  }

  Future<void> removerItem(ProductosModel producto, BuildContext context,
      ProductosVentaBloc productoVentaBloc) async {
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio,
        '/removeregisteritem/' + producto.registroItemResp.indice.toString());
    print('URL Remover Item: ' + url.toString());

    http.Response resp;
    try {
      resp = await http.delete(url, headers: <String, String>{
        HttpHeaders.authorizationHeader: prefs.token
      });
    } catch (error) {
      Navigator.of(context).pop();
      showAlert(context,
          'Problemas al eliminar un Producto, Vuelva a intentar.', Icons.error);
    }

    print(resp.body);
    if (resp.statusCode == 200 || resp.statusCode == 202) {
      productoVentaBloc.eliminarProducto(producto);
    } else if (resp.statusCode == 500) {
      Navigator.of(context).pop();
      showAlert(context, 'Problemas al elimar un Producto, Vuelva a intentar.',
          Icons.error);
    }
  }
}
