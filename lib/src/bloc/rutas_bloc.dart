import 'dart:async';
import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/model/rutas_model.dart';
import 'package:dipalza_movil/src/provider/productos_provider.dart';
import 'package:dipalza_movil/src/provider/rutas_provider.dart';
import 'package:rxdart/rxdart.dart';

class RutasBloc {
  static final RutasBloc _singleton = new RutasBloc._internal();

  factory RutasBloc() {
    return _singleton;
  }

  RutasBloc._internal() {
    obtenerListaRutas();
  }

  final _rutasController = BehaviorSubject<List<RutasModel>>();
  Stream<List<RutasModel>> get rutasStream =>
      _rutasController.stream;

  obtenerListaRutas() async {
    _rutasController.sink
        .add(await RutasProvider.rutasProvider.obtenerListaRutas());
  }

  List<RutasModel> get listaRutas => _rutasController.value;

  dispose() {
    _rutasController?.close();
  }
}
