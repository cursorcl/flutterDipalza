import 'dart:convert';

import 'package:dipalza_movil/src/bloc/productos_venta_bloc.dart';
import 'package:dipalza_movil/src/model/venta_detalle_model.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:developer' as developer;

import '../model/numerado_model.dart';
import 'package:dipalza_movil/src/share/app.navigator.dart';
class VentaProvider {
  
  static final VentaProvider ventaProvider = VentaProvider._();

  VentaProvider._() {
    //
  }

  /* ================= GRABAR =================== */

  Future<VentaModel> saveVenta(VentaModel ventaModel) async {

    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/api/ventas');
    http.Response resp = await http.post(url,
        body: VentaModel.toJson(ventaModel),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: 'Bearer ${prefs.token}',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept-Charset': 'utf-8'
        });

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      String responseBody = utf8.decode(resp.bodyBytes);
      VentaModel ventaModel =  VentaModel.fromJson(responseBody);
      return ventaModel;
    }

    // En lugar de retornar null, lanza un error
    throw Exception('Error al grabar la venta: ${resp.statusCode} ${resp.body}');
  }


  Future<VentaModel> saveItemVenta( VentaDetalleModel registro) async {
    final prefs = new PreferenciasUsuario();

    final json = ventaDetalleModelToJson(registro);
    Uri url = Uri.http(prefs.urlServicio, '/api/ventas/detalleVenta');
    http.Response resp;
    try {
      resp = await http.post(url,
          body: json,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: 'Bearer ${prefs.token}',
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept-Charset': 'utf-8'
          });
      if (resp.statusCode == 200 || resp.statusCode == 202) {
        String responseBody = utf8.decode(resp.bodyBytes);
        return  VentaModel.fromJson(responseBody);
      } else  {
        throw Exception('Error al grabar el item de venta: ${resp.statusCode} ${resp.body}');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<bool> removeVenta(int ventaId) async {
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/api/ventas/${ventaId}');
    http.Response resp = await http.delete(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader: 'Bearer ${prefs.token}',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept-Charset': 'utf-8'
        });
    if (resp.statusCode >= 200 || resp.statusCode < 300) {
      return true;
    }
    developer.log("No se ha eliminado la venta ${ventaId}");
    return false;
  }

  Future<VentaModel> removeItemVenta(int itemVentaId) async {
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/api/ventas/eliminarItemVenta/${itemVentaId}');
    http.Response resp = await http.delete(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader: 'Bearer ${prefs.token}',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept-Charset': 'utf-8'
        });
    if (resp.statusCode == 200 || resp.statusCode == 202) {
      String responseBody = utf8.decode(resp.bodyBytes);
      VentaModel ventaModel =  VentaModel.fromJson(responseBody);
      return ventaModel;
    }

    developer.log("No se ha eliminado el item de venta ${itemVentaId}");
    throw Exception("No se ha eliminado el item de venta ${itemVentaId}: ${resp.statusCode} ${resp.body}");
  }

  /* ================= LISTADOS =================== */

  /*
  * Metodo Encargado de realizar la llamada al Servicio para remover un Item(Producto) a una futura venta de un cliente.
  */
  Future<bool> removerItem(VentaDetalleModel detalleVenta, BuildContext context,
      VentaDetalleBloc productoVentaBloc) async
  {
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio,
        '/eliminarItemVenta/' + detalleVenta.id.toString());
    print('URL Remover Item: ' + url.toString());

    http.Response resp;
    try {
      resp = await http.delete(url, headers: <String, String>{
        HttpHeaders.authorizationHeader: prefs.token,
        'Accept-Charset': 'utf-8'
      });
    } catch (error) {
      AppNavigator.pop();
      showAlert(context,
          'Problemas al eliminar un Producto, Vuelva a intentar.', Icons.error);
      return false;
    }

    if (resp.statusCode == 200 || resp.statusCode == 202) {
      productoVentaBloc.eliminarVentaDetalle(detalleVenta);
      return true;
    } else if (resp.statusCode == 500) {
      AppNavigator.pop();
      showAlert(context, 'Problemas al elimar un Producto, Vuelva a intentar.',
          Icons.error);
      return false;
    }
    return false;
  }

  /*
  * Metodo Encargado de realizar la llamada al Servicio para otener las futuras ventas ingresadas por el vendedor para el día que se está trabajando.
  */
  Future<List<VentaModel>> obtenerListaVentas() async {
    try {
      final prefs = new PreferenciasUsuario();
      var fechaFacturacion = prefs.fechaFacturacion.toIso8601String().split('T').first;


      Uri url = Uri.http(
        prefs.urlServicio,
        '/api/ventas/vendedor/${prefs.vendedor}/fecha',
        {'fecha': fechaFacturacion},
      );

      final resp = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${prefs.token}',
        'Accept-Charset': 'utf-8'
      });

      if (resp.statusCode == 200 || resp.statusCode == 202) {
        String responseBody = utf8.decode(resp.bodyBytes);
        List<VentaModel> listaVentas = VentaModel.listFromJson(responseBody);

        if(listaVentas.length == 0) {
             return [];
        }
        return listaVentas;
      }
    } catch (error) {
      developer.log("Se ha producido un error al cargar las ventas", error: error);
      return [];
    }
    return [];
  }

  /**
   * Obtiene el detalle de productos asociados a una venta.
   * @param ventaId El ID de la venta para la cual se obtendrán los detalles.
   */
  Future<List<VentaDetalleModel>> obtenerListaVentasDetalle(int ventaId) async {
    try {
      final prefs = new PreferenciasUsuario();
      Uri url = Uri.http(prefs.urlServicio,
          '/api/ventas/${ventaId}/detalles');
      developer.log('URL Lista Ventas Item: ' + url.toString());

      final resp = await http.get(url, headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer ${prefs.token}',
        'Accept-Charset': 'utf-8'
      });
      developer.log(resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 202) {
        List<VentaDetalleModel> listaVentasItem =
        listVentaDetalleModel(resp.body);

        return listaVentasItem;
      }
    } catch (error, stackTrace) {
      developer.log(
        'Ocurrió un error al cargar las ventas detalle.',
        name: 'cl.eos.dipalza', // Un nombre para filtrar en la consola
        error: error,        // El objeto de la excepción
        stackTrace: stackTrace,    // El stack trace
        level: 1000,                // Nivel de severidad (ej. 900 para warning, 1000 para error grave)
      );
    }
    return [];
  }



  Future<NumeradoModel> actualizarNumerado(NumeradoModel numerado) async {
    try {
      final prefs = new PreferenciasUsuario();
      final token = prefs.token;
      final json = numeradoModelToJson(numerado);
      Uri url = Uri.http(prefs.urlServicio, '/api/ventas/updateNumerado');
      final resp = await http.put(url, headers: {'Accept-Charset': 'utf-8', 'Content-Type': 'application/json','Authorization': 'Bearer $token',}, body: json);
      return numeradoModelFromJson(resp.body);
    } catch (error) {
      developer.log("No se ha podido actualizar el estado del numerado:" + error.toString());
      throw error;
    }
  }
}
