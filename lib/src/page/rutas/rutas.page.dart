// Archivo: rutas.page.dart
// ignore_for_file: unused_field

import 'package:dipalza_movil/src/model/rutas_model.dart';
import 'package:dipalza_movil/src/share/app.navigator.dart';
import 'package:flutter/material.dart';

import '../../bloc/rutas_bloc.dart';
import '../../utils/utils.dart';

class RutasPage extends StatefulWidget {
  final bool multiSelect;
  final List<RutasModel> seleccionInicial;
  final bool obligatorio;

  const RutasPage({
    Key? key,
    this.multiSelect = false,
    this.seleccionInicial = const [],
    this.obligatorio = false,
  }) : super(key: key);

  @override
  _RutasPageState createState() => _RutasPageState();
}

class _RutasPageState extends State<RutasPage> {
  final RutasBloc rutasBloc = RutasBloc();

  late List<RutasModel> _rutasFiltradas;
  final TextEditingController _searchController = TextEditingController();
  bool _verBuscar = false;
  late Set<String> _codigosSeleccionados;

  @override
  void initState() {
    super.initState();
    _codigosSeleccionados =
        widget.seleccionInicial.map((r) => r.codigo).toSet();
    _searchController.addListener(_filtrarRutas);

    // Reintenta si no hay datos
    if (rutasBloc.listaRutas.isEmpty) {
      rutasBloc.obtenerListaRutas();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    //rutasBloc.dispose();
    super.dispose();
  }

  void _filtrarRutas() {
    final query = _searchController.text.toLowerCase();
    rutasBloc.filtrarRutas(query);
  }

  void _guardarSeleccion() {
    final seleccionadas = rutasBloc.listaRutas
        .where((r) => _codigosSeleccionados.contains(r.codigo))
        .toList();
    AppNavigator.pop(seleccionadas);
  }

  void _alternarSeleccion(String codigo) {
    setState(() {
      if (_codigosSeleccionados.contains(codigo)) {
        _codigosSeleccionados.remove(codigo);
      } else {
        _codigosSeleccionados.add(codigo);
      }
    });
  }

  _card(RutasModel ruta) {
    final seleccionada = _codigosSeleccionados.contains(ruta.codigo);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          child: const Icon(Icons.add_box_outlined),
          backgroundColor: colorRojoBase(),
          foregroundColor: Colors.white,
        ),
        title: Text(ruta.descripcion,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
                color: Colors.black)),
        subtitle: Row(
          children: <Widget>[
            Text(ruta.codigo,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.0,
                    color: Colors.grey)),
          ],
        ),
        trailing: widget.multiSelect
            ? Checkbox(
                value: seleccionada,
                onChanged: (_) => _alternarSeleccion(ruta.codigo),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  AppNavigator.pop(ruta);
                }),
        onTap: widget.multiSelect
            ? () => _alternarSeleccion(ruta.codigo)
            : () {
                AppNavigator.pop(ruta);
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
        appBar: AppBar(
          backgroundColor: colorRojoBase(),
          automaticallyImplyLeading: !widget.obligatorio,
          title: Text(widget.multiSelect ? 'Seleccionar Rutas' : 'Seleccionar Ruta'),
          actions: <Widget>[
            if (widget.multiSelect)
              IconButton(
                icon: const Icon(Icons.check),
                tooltip: 'Guardar',
                onPressed: (widget.obligatorio && _codigosSeleccionados.isEmpty)
                    ? null
                    : _guardarSeleccion,
              ),
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Buscar',
              onPressed: () {
                setState(() {
                  _verBuscar = true;
                });
              },
            ),
          ],
          bottom: _verBuscar
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(56.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        suffixIcon: new IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            _searchController.clear();
                            rutasBloc
                                .limpiarFiltro(); // ← Usar BLoC para limpiar
                            setState(() {
                              _verBuscar = false;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : null,
        ),
        body: RefreshIndicator(
          onRefresh: () => rutasBloc.obtenerListaRutas(),
          child: StreamBuilder<List<RutasModel>>(
            stream: rutasBloc.rutasStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 64),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                          ElevatedButton(
                            onPressed: () => rutasBloc
                                .limpiarFiltro(), //  rutasBloc.cargarRutas(widget.listaRutas),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando rutas...'),
                    ],
                  ),
                );
              }
              final rutasFiltradas = snapshot.data!; // ← Los datos del stream
              if (snapshot.data!.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Text('No se encontraron rutas.'),
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: rutasFiltradas.length,
                itemBuilder: (context, index) {
                  final ruta = rutasFiltradas[index];
                  return _card(ruta);
                },
              );
            },
          ),
        ));

    if (widget.obligatorio) {
      return PopScope(canPop: false, child: scaffold);
    }
    return scaffold;
  }
}
