import 'package:dipalza_movil/src/bloc/condicion_venta_bloc.dart';
import 'package:dipalza_movil/src/bloc/productos_bloc.dart';
import 'package:dipalza_movil/src/bloc/productos_venta_bloc.dart';
import 'package:dipalza_movil/src/log/db_log_provider.dart';
import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/condicion-model.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/model/registro_item_model.dart';
import 'package:dipalza_movil/src/model/registro_item_resp_model.dart';
import 'package:dipalza_movil/src/model/transmitir_model.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:collection/collection.dart';

class VentaProvider {
  
  static final VentaProvider ventaProvider = VentaProvider._();

  VentaProvider._() {
     CondicionVentaBloc().obtenerListaCondicionesVenta();
    //
  }

  /*
  * Metodo Encargado de realizar la llamada al Servicio para registrar un Item(Producto) a una futura venta de un cliente.
  */
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
            HttpHeaders.authorizationHeader: prefs.token,
            'Content-Type': 'application/json; charset=UTF-8',
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

  /*
  * Metodo Encargado de realizar la llamada al Servicio para remover un Item(Producto) a una futura venta de un cliente.
  */
  Future<bool> removerItem(ProductosModel producto, BuildContext context,
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
      return false;
    }

    print(resp.body);
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
      Uri url = Uri.http(prefs.urlServicio, '/listsales/sale/${prefs.vendedor}');
      DBLogProvider.db.nuevoLog(creaLogInfo('VentasProvider', 'obtenerListaVentas', 'Inicio'));
      print('URL Lista Ventas: ' + url.toString());

      final resp = await http.get(url, headers: <String, String>{ HttpHeaders.authorizationHeader: prefs.token });
      print(resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 202) {
        List<VentaModel> listaVentas = ventaModelFromJson(resp.body);

        if(listaVentas.length == 0) {
             return [];
        }

        listaVentas.sort((a, b) => b.fecha.compareTo(a.fecha));

        var condiciones = CondicionVentaBloc().listaCondicionVenta;
        List<ClientesModel> listaCliente;
        url = Uri.http(prefs.urlServicio, '/clients/seller/${prefs.vendedor}/route/${prefs.ruta}');
        final respCliente = await http.get(url, headers: <String, String>{ HttpHeaders.authorizationHeader: prefs.token});

        if (respCliente.statusCode == 200 || respCliente.statusCode == 202) {
          listaCliente = clientesModelFromJson(respCliente.body);

          listaVentas.forEach((objVenta) {
            CondicionVentaModel condicionVenta = condiciones.firstWhereOrNull((c) => objVenta.condicionventacode == c.codigo);

            if(condicionVenta != null)
            {
              objVenta.condicionventa = condicionVenta;
            }
            else {
              objVenta.condicionventa = condiciones.first;
              objVenta.condicionventacode = condiciones.first.codigo;
            }
            ClientesModel cliente = listaCliente.firstWhere((objCliente) => objVenta.rut == objCliente.rut, orElse: () => null);
            if (cliente != null) {
              objVenta.razon = cliente.razon;
              objVenta.cliente = cliente;
            } else {
              objVenta.razon = getFormatRut(objVenta.rut);
            }
          });
        }




        return listaVentas;
      }
    } catch (error) {
      DBLogProvider.db.nuevoLog(creaLogError(
          'VentasProvider', 'obtenerListaVentas', error.toString()));
      return [];
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
    } catch (error) {
      Navigator.of(context).pop();
      DBLogProvider.db.nuevoLog(
          creaLogError('VentaProvider', 'transmitirVentas', error.toString()));
      showAlert(
          context,
          'Problemas con al transmisión las Ventas, Vuelva a intentar.',
          Icons.error);
    }

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

    return false;
  }
}
