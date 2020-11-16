import 'dart:async';

import 'package:dipalza_movil/src/model/producto_model.dart';

class ProductosValidator {
 

  final validaProductos = StreamTransformer<List<ProductosModel>,
      List<ProductosModel>>.fromHandlers(handleData: (productos, sink) {
    final List<ProductosModel> newList = [];

    // for (var item in productos) {
    //   if (item.asignado != null && item.asignado == prefs.usuario) {
    //     item.iconoFema =
    //         getSimboloFema(item.tpoperacion.simbolo, item.levelFema);
    //     item.enlazada = true;
    //     prefs.idOperacionEnlazada = item.idoperacion;
    //     newList.add(item);
    //     break;
    //   }
    // }

    sink.add(newList);
  });


}