import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:dipalza_movil/src/model/rutas_model.dart';
import 'package:dipalza_movil/src/provider/rutas_provider.dart';

class RutasBloc {
  // El singleton
  static final RutasBloc _singleton = new RutasBloc._internal();
  // El Behavior que mantiene el ultimo valor
  final _rutasController = BehaviorSubject<List<RutasModel>>();
  List<RutasModel> _rutasOriginales = [];

  factory RutasBloc() {
    return _singleton;
  }

  RutasBloc._internal() {
    obtenerListaRutas();
  }
  // Define el stream, para mantener la información actualizada
  Stream<List<RutasModel>> get rutasStream => _rutasController.stream;
  // El valor actual del bloc
  List<RutasModel> get listaRutas => _rutasController.value;

  // Método que actualiza el valor del behavior
  obtenerListaRutas() async {
    _rutasController.sink.add(await RutasProvider.rutasProvider.obtenerListaRutas());
  }

  // Cargar rutas iniciales
  void cargarRutas(List<RutasModel> rutas) {
    _rutasOriginales = List.from(rutas);
    _rutasController.sink.add(rutas);
  }

  // Filtrar rutas
  void filtrarRutas(String query) {
    if (query.isEmpty) {
      _rutasController.sink.add(_rutasOriginales);
      return;
    }

    final rutasFiltradas = _rutasOriginales.where((ruta) =>
    ruta.descripcion.toLowerCase().contains(query.toLowerCase()) ||
        ruta.codigo.toLowerCase().contains(query.toLowerCase())
    ).toList();

    _rutasController.sink.add(rutasFiltradas);
  }

  // Limpiar filtro
  void limpiarFiltro() {
    _rutasController.sink.add(_rutasOriginales);
  }

  // Agregar nueva ruta
  void agregarRuta(RutasModel nuevaRuta) {
    _rutasOriginales.add(nuevaRuta);
    _rutasController.sink.add(_rutasOriginales);
  }

  // Eliminar ruta
  void eliminarRuta(String codigoRuta) {
    _rutasOriginales.removeWhere((ruta) => ruta.codigo == codigoRuta);
    _rutasController.sink.add(_rutasOriginales);
  }

  // Cierra el stream para liberar memoria
  dispose() {
    _rutasController.close();
  }
}
