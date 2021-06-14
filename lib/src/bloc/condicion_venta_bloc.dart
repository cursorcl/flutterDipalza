import 'dart:async';

import 'package:dipalza_movil/src/model/condicion-model.dart';
import 'package:dipalza_movil/src/provider/condicion_venta_provider.dart';
import 'package:rxdart/rxdart.dart';

class CondicionVentaBloc  {

  static final CondicionVentaBloc _singleton = new CondicionVentaBloc._internal();
  final _condicionVentaController = BehaviorSubject<List<CondicionVentaModel>>();

  factory CondicionVentaBloc() {
    return _singleton;
  }

  CondicionVentaBloc._internal() {
    obtenerListaCondicionesVenta();
  }

 Stream<List<CondicionVentaModel>> get condicionVentaStream => _condicionVentaController.stream;
 List<CondicionVentaModel> get listaCondicionVenta => _condicionVentaController.value;

  obtenerListaCondicionesVenta() async {
    _condicionVentaController.sink.add(await CondicionVentaProvider.condicionVentaProvider.obtenerListaCondicionVenta());
  }

  dispose() {
    _condicionVentaController?.close();
  }
}
