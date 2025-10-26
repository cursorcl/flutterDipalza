import 'dart:convert';

import 'package:dipalza_movil/src/bloc/condicion_venta_bloc.dart';
import 'package:dipalza_movil/src/bloc/productos_bloc.dart';
import 'package:dipalza_movil/src/bloc/productos_venta_bloc.dart';
import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/model/venta_detalle_item_model.dart';
import 'package:dipalza_movil/src/model/registro_item_resp_model.dart';
import 'package:dipalza_movil/src/model/transmitir_model.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:developer' as developer;

import '../services/locator.dart';

class VentaProvider {
  
  static final VentaProvider ventaProvider = VentaProvider._();
  final CondicionVentaBloc _condicionVentaBloc = locator<CondicionVentaBloc>();

  VentaProvider._() {
    //
  }

  /*
  * Metodo Encargado de realizar la llamada al Servicio para registrar un Item(Producto) a una futura venta de un cliente.
  */
  Future<RegistroItemRespModel> registrarItem(
      VentaDetalleItemModel registro, BuildContext context) async {
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/registeritem/');
    http.Response resp;
    try {
      resp = await http.post(url,
          body: ventaDetalleItemModelToJson(registro),
          headers: <String, String>{
            HttpHeaders.authorizationHeader: prefs.token,
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept-Charset': 'utf-8'
          });
      print(resp.body);
      if (resp.statusCode == 200 || resp.statusCode == 202) {
        String responseBody = utf8.decode(resp.bodyBytes);
        return registroItemRespModelFromJson(responseBody);
      } else if (resp.statusCode == 500) {
        Navigator.of(context).pop();
        showAlert(context, 'Problemas al agregar un Producto, Vuelva a intentar.',
            Icons.error);
      }
    } catch (error) {
      Navigator.of(context).pop();
      showAlert(context, 'Problemas al agregar un Producto, Vuelva a intentar.',
          Icons.error);
    }



    return registroItemRespModelFromJson('{}');
  }

  /*
  * Metodo Encargado de realizar la llamada al Servicio para remover un Item(Producto) a una futura venta de un cliente.
  */
  Future<bool> removerItem(ProductosModel producto, BuildContext context,
      ProductosVentaBloc productoVentaBloc) async {
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio,
        '/removeregisteritem/' + producto.registroItemResp!.indice.toString());
    print('URL Remover Item: ' + url.toString());

    http.Response resp;
    try {
      resp = await http.delete(url, headers: <String, String>{
        HttpHeaders.authorizationHeader: prefs.token,
        'Accept-Charset': 'utf-8'
      });
    } catch (error) {
      Navigator.of(context).pop();
      showAlert(context,
          'Problemas al eliminar un Producto, Vuelva a intentar.', Icons.error);
      return false;
    }

    if (resp.statusCode == 200 || resp.statusCode == 202) {
      productoVentaBloc.eliminarProducto(producto);
      return true;
    } else if (resp.statusCode == 500) {
      Navigator.of(context).pop();
      showAlert(context, 'Problemas al elimar un Producto, Vuelva a intentar.',
          Icons.error);
      return false;
    }
    return false;
  }

  /*
  * Metodo Encargado de realizar la llamada al Servicio para otener las futuras ventas ingresadas por el vendedor.
  */
  Future<List<VentaModel>> obtenerListaVentas() async {
    try {
      final prefs = new PreferenciasUsuario();
      var fechaFacturacion = prefs.fechaFacturacion.toIso8601String().split('T').first;


      Uri url = Uri.http(
        prefs.urlServicio,
        '/api/ventas/header/vendedor/${prefs.vendedor}/fecha',
        {'fecha': fechaFacturacion},
      );

      final resp = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${prefs.token}',
        'Accept-Charset': 'utf-8'
      });

      if (resp.statusCode == 200 || resp.statusCode == 202) {
        String responseBody = utf8.decode(resp.bodyBytes);
        List<VentaModel> listaVentas = ventaModelFromJson(responseBody);

        if(listaVentas.length == 0) {
             return [];
        }
        return listaVentas;
      }
    } catch (error) {
      return [];
    }
    return [];
  }




  Future<List<VentaDetalleItemModel>> obtenerListaVentasDetalle(int ventaId) async {
    try {
      final prefs = new PreferenciasUsuario(); //RegistroItemRespModel
      Uri url = Uri.http(prefs.urlServicio,
          '/api/ventas/${ventaId}/detalles');
      developer.log('URL Lista Ventas Item: ' + url.toString());

      final resp = await http.get(url, headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer ${prefs.token}',
        'Accept-Charset': 'utf-8'
      });
      developer.log(resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 202) {
        List<VentaDetalleItemModel> listaVentasItem =
        listVentaDetalleItemModel(resp.body);

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




  /*
  * Metodo Encargado de realizar la llamada al Servicio para otener la lista de Items(Productos) que contempla una futura venta realizada por el Vendedor.
  */
  Future<List<ProductosModel>> obtenerListaVentasItem(
      String rutCliente, String codeCliente, int fecha) async {
    try {
      final prefs = new PreferenciasUsuario(); //RegistroItemRespModel
      Uri url = Uri.http(prefs.urlServicio,
          '/listsales/sale/${prefs.vendedor}/rut/$rutCliente/code/$codeCliente/date/$fecha');
      DBLogProvider.db.nuevoLog(
          creaLogInfo('VentasProvider', 'obtenerListaVentasItem', 'Inicio'));
      print('URL Lista Ventas Item: ' + url.toString());

      final resp = await http.get(url, headers: <String, String>{
        HttpHeaders.authorizationHeader: prefs.token
      });
      print(resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 202) {
        List<RegistroItemRespModel> listaVentasItem =
            listRegistroItemRespModelFromJson(resp.body);

        List<ProductosModel> _listaProductos = ProductosBloc().listaProductos;
        List<ProductosModel> _listaProductosFinal = [];

        listaVentasItem.forEach((item) {
          for (ProductosModel producto in _listaProductos) {
            if (item.articulo == producto.articulo) {
              ProductosModel newRegistro = producto.clone();
              newRegistro.registroItemResp = item;
              _listaProductosFinal.add(newRegistro);
              break;
            }
          }
        });

        return _listaProductosFinal;
      }
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError(
          'VentasProvider', 'obtenerListaVentasItem', error.toString()));
      return [];
    }
    return [];
  }

/*
  * Metodo Encargado de realizar la llamada al Servicio para realizar la transmisión final de una futura venta que pasa a ser una Venta Finalizada.
  */
  Future<bool> transmitirVentas(
      BuildContext context, TransmitirModel transmitir) async {
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(prefs.urlServicio, '/registersale');
    print('URL Transmitir Venta: ' + url.toString());

    http.Response resp;
    try {
      resp = await http.post(url,
          body: transmitirModelToJson(transmitir),
          headers: <String, String>{
            HttpHeaders.authorizationHeader: prefs.token,
            'Content-Type': 'application/json; charset=UTF-8',
          });
      print(resp.body);
      if (resp.statusCode == 200 || resp.statusCode == 202) {
        return true;
        // return resp.body == 'true' ? true : false;
      } else if (resp.statusCode == 500) {
        Navigator.of(context).pop();
        DBLogProvider.db.nuevoLog(creaLogError(
            'VentaProvider', 'transmitirVentas', resp.body.toString()));
        showAlert(
            context,
            'Problemas con la transmisión las Ventas, Vuelva a intentar.',
            Icons.error);
      }
    } catch (error) {
      Navigator.of(context).pop();
      DBLogProvider.db.nuevoLog(
          creaLogError('VentaProvider', 'transmitirVentas', error.toString()));
      showAlert(
          context,
          'Problemas con al transmisión las Ventas, Vuelva a intentar.',
          Icons.error);
    }



    return false;
  }
}
