import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/venta_detalle_model.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/share/estado.venta.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';

import '../model/numerado_model.dart';
import '../services/api_client.dart';

class VentaProvider {
  static final VentaProvider ventaProvider = VentaProvider._();
  final _dio = ApiClient().dio;

  VentaProvider._() {
    //
  }

  /* ================= GRABAR =================== */

  Future<VentaModel> saveVenta(VentaModel ventaModel) async {
    /*
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/api/ventas');
    http.Response resp = await http.post(url, body: VentaModel.toJson(ventaModel), headers: <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}',
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept-Charset': 'utf-8'
    });

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      String responseBody = utf8.decode(resp.bodyBytes);
      VentaModel ventaModel = VentaModel.fromJson(responseBody);
      return ventaModel;
    }
    */
    try {
      final response = await _dio.post(
        '/api/ventas',
        data: VentaModel.toJson(ventaModel),
      );

      return VentaModel.fromMap(response.data);
    } on DioException catch (e) {
      developer.log("No se ha grabado la venta ${ventaModel}");

      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      throw Exception("Error al garabar la venta $ventaModel. "
          "Status: $statusCode, "
          "Data: $data, "
          "Mensaje Dio: ${e.message}");
    }
  }

  Future<VentaModel> saveItemVenta(VentaDetalleModel registro) async {
    /*
    final prefs = new PreferenciasUsuario();
    final json = ventaDetalleModelToJson(registro);
    Uri url = Uri.http(prefs.urlServicio, '/api/ventas/detalleVenta');
    http.Response resp;
    try {
      resp = await http.post(url, body: json, headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept-Charset': 'utf-8'
      });
      if (resp.statusCode == 200 || resp.statusCode == 202) {
        String responseBody = utf8.decode(resp.bodyBytes);
        return VentaModel.fromJson(responseBody);
      } else {
        throw Exception('Error al grabar el item de venta: ${resp.statusCode} ${resp.body}');
      }
     */
    try {
      final response = await _dio.post(
        '/api/ventas/detalleVenta',
        data: ventaDetalleModelToJson(registro),
      );
      return VentaModel.fromMap(response.data);
    } on DioException catch (e) {
      developer.log("No se ha grabado el detalle de venta ${registro}");

      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      throw Exception("Error al garabar el detalle venta $registro. "
          "Status: $statusCode, "
          "Data: $data, "
          "Mensaje Dio: ${e.message}");
    }
  }

  Future<bool> removeVenta(int ventaId) async {
    /*
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/api/ventas/${ventaId}');
    http.Response resp = await http.delete(url, headers: <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}',
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept-Charset': 'utf-8'
    });
    if (resp.statusCode >= 200 || resp.statusCode < 300) {
      return true;
    }
    developer.log("No se ha eliminado la venta ${ventaId}");
    return false;
     */

    try {
      await _dio.delete('/api/ventas/${ventaId}');
      return true;
    } catch (error) {
      developer.log("No se ha eliminado el item de venta ${ventaId}");
      return false;
    }
  }

  Future<void> removeItemVenta(int itemVentaId) async {
    /*
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/api/ventas/eliminarItemVenta/${itemVentaId}');
    http.Response resp = await http.delete(url, headers: <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}',
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept-Charset': 'utf-8'
    });
    if (resp.statusCode == 200 || resp.statusCode == 202) {
      String responseBody = utf8.decode(resp.bodyBytes);
      VentaModel ventaModel = VentaModel.fromJson(responseBody);
      return ventaModel;
    }

    developer.log("No se ha eliminado el item de venta ${itemVentaId}");
    throw Exception("No se ha eliminado el item de venta ${itemVentaId}: ${resp.statusCode} ${resp.body}");
    */

    try {
      await _dio.delete('/api/ventas/eliminarItemVenta/${itemVentaId}');

      return;
    } on DioException catch (e) {
      developer.log("No se ha eliminado el item de venta ${itemVentaId}");

      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      throw Exception("Error eliminando item $itemVentaId. "
          "Status: $statusCode, "
          "Data: $data, "
          "Mensaje Dio: ${e.message}");
    }
  }

  /*
  * Metodo Encargado de realizar la llamada al Servicio para otener las futuras ventas ingresadas por el vendedor para el día que se está trabajando.
  */
  Future<List<VentaModel>> obtenerListaVentas() async {
    /*
    try {
      final prefs = new PreferenciasUsuario();
      var fechaFacturacion = prefs.fechaFacturacion.toIso8601String().split('T').first;

      Uri url = Uri.http(
        prefs.urlServicio,
        '/api/ventas/vendedor/${prefs.vendedor}/fecha',
        {'fecha': fechaFacturacion},
      );

      final resp = await http.get(url, headers: {HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}', 'Accept-Charset': 'utf-8'});

      if (resp.statusCode == 200 || resp.statusCode == 202) {
        String responseBody = utf8.decode(resp.bodyBytes);
        List<VentaModel> listaVentas = VentaModel.listFromJson(responseBody);

        if (listaVentas.length == 0) {
          return [];
        }
        return listaVentas;
      }
    } catch (error) {
      developer.log("Se ha producido un error al cargar las ventas", error: error);
      return [];
    }
    return [];

     */

    final prefs = new PreferenciasUsuario();
    var fechaFacturacion =
        prefs.fechaFacturacion.toIso8601String().split('T').first;
    try {
      final response = await _dio.get(
          '/api/ventas/vendedor/${prefs.vendedor}/fecha',
          queryParameters: {'fecha': fechaFacturacion});

      final List<dynamic> data = response.data;

      return data.map((json) => VentaModel.fromMap(json)).toList();
    } on DioException catch (e) {
      developer.log(
          "No se ha podido obtener la ventas para el vendedor ${prefs.vendedor} el día ${fechaFacturacion}  ",
          error: e);
    }
    return [];
  }

  /**
   * Obtiene el detalle de productos asociados a una venta.
   * @param ventaId El ID de la venta para la cual se obtendrán los detalles.
   */
  Future<List<VentaDetalleModel>> obtenerListaVentasDetalle(int ventaId) async {
    /*
    try {
      final prefs = new PreferenciasUsuario();
      Uri url = Uri.http(prefs.urlServicio, '/api/ventas/${ventaId}/detalles');
      developer.log('URL Lista Ventas Item: ' + url.toString());

      final resp =
          await http.get(url, headers: <String, String>{HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}', 'Accept-Charset': 'utf-8'});
      developer.log(resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 202) {
        List<VentaDetalleModel> listaVentasItem = listVentaDetalleModel(resp.body);

        return listaVentasItem;
      }
    } catch (error, stackTrace) {
      developer.log(
        'Ocurrió un error al cargar las ventas detalle.',
        name: 'cl.eos.dipalza', // Un nombre para filtrar en la consola
        error: error, // El objeto de la excepción
        stackTrace: stackTrace, // El stack trace
        level: 1000, // Nivel de severidad (ej. 900 para warning, 1000 para error grave)
      );
    }
    return [];
    */

    try {
      final response = await _dio.get('/api/ventas/${ventaId}/detalles');

      final List<dynamic> data = response.data;

      return data.map((json) => VentaDetalleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      developer.log("Ocurrió un error al cargar las ventas detalle.  ",
          error: e);
    }
    return [];
  }

  Future<NumeradoModel> actualizarNumerado(NumeradoModel numerado) async {
    /*
    try {
      final prefs = new PreferenciasUsuario();
      final token = prefs.access_token;
      final json = numeradoModelToJson(numerado);
      Uri url = Uri.http(prefs.urlServicio, '/api/ventas/updateNumerado');
      final resp = await http.put(url,
          headers: {
            'Accept-Charset': 'utf-8',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json);
      return numeradoModelFromJson(resp.body);
    } catch (error) {
      developer.log("No se ha podido actualizar el estado del numerado:" + error.toString());
      throw error;
    }
     */

    try {
      final response = await _dio.post('/api/ventas/updateNumerado',
          data: numeradoModelToJson(numerado));
      return numeradoModelFromJson(response.data);
    } on DioException catch (e) {
      developer.log(
          "No se ha podido actualizar el estado del numerado:" + e.toString());

      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      throw Exception("No se ha podido actualizar el estado del numerado "
          "Status: $statusCode, "
          "Data: $data, "
          "Mensaje Dio: ${e.message}");
    }
  }

  Future<VentaModel?> obtenerUltimaVenta(ClientesModel cliente) async {
    /*
    final prefs = new PreferenciasUsuario();
    final token = prefs.access_token;
    final clientIdQuery = {"rut": cliente.rut, "codigo": cliente.codigo};
    final json = jsonEncode(clientIdQuery);
    Uri url = Uri.http(prefs.urlServicio, '/api/ventas/ultimaventacliente');

    try {
      http.Response resp = await http.post(url, body: json, headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept-Charset': 'utf-8'
      });
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        String responseBody = utf8.decode(resp.bodyBytes);
        return VentaModel.fromJson(responseBody);
      } else if (resp.statusCode == 404) {
        return null;
      } else
        throw Exception('Error al grabar el item de venta: ${resp.statusCode} ${resp.body}');
    } catch (error) {
      developer.log("Se ha producido un error al obtener la última venta del cliente ${cliente.razon}", error: error);
      throw Exception("Se ha producido un error al obtener la última venta del cliente ${cliente.razon}: ${error}");
    }
     */

    try {
      final clientIdQuery = {"rut": cliente.rut, "codigo": cliente.codigo};
      final response = await _dio.post('/api/ventas/ultimaventacliente',
          data: jsonEncode(clientIdQuery));

      return VentaModel.fromJson(response.data);
    } on DioException catch (e) {
      developer.log(
          "Se ha producido un error al obtener la última venta del cliente ${cliente.razon}",
          error: e);
      throw Exception(
          "Se ha producido un error al obtener la última venta del cliente ${cliente.razon}: ${e}");
    }
  }

  Future<VentaModel> cambiarEstadoVenta(
      VentaModel venta, EstadoVenta estadoVenta) async {
    /*
    final prefs = new PreferenciasUsuario();
    final token = prefs.access_token;
    final estadoVentaQuery = {"idVenta": venta.id, "estadoVenta": estadoVenta.name};
    final json = jsonEncode(estadoVentaQuery);
    Uri url = Uri.http(prefs.urlServicio, '/api/ventas/updateEstadoVenta');

    try {
      http.Response resp = await http.post(url, body: json, headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer ${prefs.access_token}',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept-Charset': 'utf-8',
      });
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        String responseBody = utf8.decode(resp.bodyBytes);
        return VentaModel.fromJson(responseBody);
      } else
        throw Exception('Error al grabar el item de venta: ${resp.statusCode} ${resp.body}');
    } catch (error) {
      developer.log("Se ha producido un error al actualiar el estado de la venta ${venta.id}", error: error);
      throw Exception("Se ha producido un error al actualiar el estado de la ventae ${venta.id}: ${error}");
    }
     */

    try {
      final estadoVentaQuery = {
        "idVenta": venta.id,
        "estadoVenta": estadoVenta.name
      };
      final response = await _dio.post('/api/ventas/updateEstadoVenta',
          data: jsonEncode(estadoVentaQuery));

      return VentaModel.fromMap(response.data);
    } on DioException catch (e) {
      developer.log(
          "Se ha producido un error al actualiar el estado de la venta ${venta.id}",
          error: e);
      throw Exception(
          "Se ha producido un error al actualiar el estado de la ventae ${venta.id}: ${e}");
    }
  }
}
