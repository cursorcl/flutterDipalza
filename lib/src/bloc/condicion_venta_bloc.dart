// src/bloc/condicion_venta_bloc.dart

import 'dart:async';
import 'package:dipalza_movil/src/model/condicion_venta_model.dart';
import 'package:dipalza_movil/src/provider/condicion_venta_provider.dart';
import 'package:rxdart/rxdart.dart';

// MODIFICADO: Ya no es un Singleton, es una clase normal.
class CondicionVentaBloc {

  // El BehaviorSubject sigue siendo una excelente elección.
  final _condicionVentaController = BehaviorSubject<List<CondicionVentaModel>>();

  // Streams y getters públicos se mantienen igual.
  Stream<List<CondicionVentaModel>> get condicionVentaStream => _condicionVentaController.stream;
  List<CondicionVentaModel> get listaCondicionVenta => _condicionVentaController.value;

  // MODIFICADO: El constructor ahora es público y simple.
  CondicionVentaBloc() {
    // La obtención de datos se sigue llamando al momento de la creación.
    obtenerListaCondicionesVenta();
  }

  Future<void> obtenerListaCondicionesVenta() async {
    // Añadimos un try-catch por robustez.
    try {
      final data = await CondicionVentaProvider.condicionVentaProvider.obtenerListaCondicionVenta();
      if (!_condicionVentaController.isClosed) {
        _condicionVentaController.sink.add(data);
      }
    } catch (e) {
      if (!_condicionVentaController.isClosed) {
        _condicionVentaController.addError(e);
      }
    }
  }

  // El método dispose es crucial. Provider nos ayudará a llamarlo.
  void dispose() {
    _condicionVentaController.close();
  }
}