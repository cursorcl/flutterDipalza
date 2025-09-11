// Archivo: rutas.page.dart
import 'package:flutter/material.dart';
import 'package:dipalza_movil/src/model/rutas_model.dart';

import '../../bloc/rutas_bloc.dart';
import '../../utils/utils.dart';

class RutasPage extends StatefulWidget {

  final List<RutasModel> listaRutas;
  const RutasPage({Key? key, required this.listaRutas}) : super(key: key);

  @override
  _RutasPageState createState() => _RutasPageState();
}

class _RutasPageState extends State<RutasPage> {
  final RutasBloc rutasBloc = RutasBloc();

  late List<RutasModel> _rutasFiltradas;
  final TextEditingController _searchController = TextEditingController();
  bool _verBuscar = false;

  @override
  void initState() {
    super.initState();
    // Cargar las rutas iniciales en el BLoC
    rutasBloc.cargarRutas(widget.listaRutas);

    // Escuchar cambios en el campo de búsqueda
    _searchController.addListener(_filtrarRutas);
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

  _card(RutasModel ruta) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          child: Icon(Icons.add_box_outlined),
          backgroundColor: colorRojoBase(),
          foregroundColor: Colors.white,
        ),
        title: Text(ruta.descripcion,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
                color: Colors.black)),
        subtitle: Row(
          children: <Widget>[
            Text(ruta.codigo,  style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10.0,
                color: Colors.grey)),
          ],
        ),
        trailing:
        IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: () {}),
        onTap: () {
          Navigator.pop(context, ruta);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: const Text('Seleccionar Ruta'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () {
              setState(() {
                _verBuscar = true;
                }
              );
            },
          ),
        ],
        bottom: _verBuscar ? PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: new IconButton(
                  color: Colors.white,
                  icon: new Icon(Icons.cancel),
                  onPressed: () {
                    _searchController.clear();
                    rutasBloc.limpiarFiltro(); // ← Usar BLoC para limpiar
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
      body: StreamBuilder<List<RutasModel>>(
        stream: rutasBloc.rutasStream, // ← Aquí está el stream del BLoC
        builder: (context, snapshot) { // ← AQUÍ aparece el snapshot

          // 1. MANEJO DE ERRORES
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => rutasBloc.cargarRutas(widget.listaRutas),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // 2. ESTADO DE CARGA
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

          // 3. DATOS DISPONIBLES
          final rutasFiltradas = snapshot.data!; // ← Los datos del stream

          // 4. LISTA VACÍA
          if (rutasFiltradas.isEmpty) {
            return const Center(
              child: Text('No se encontraron rutas.'),
            );
          }

          // 5. MOSTRAR LISTA
          return ListView.builder(
            itemCount: rutasFiltradas.length,
            itemBuilder: (context, index) {
              final ruta = rutasFiltradas[index];
              return _card(ruta);
            },
          );
        },
      ),
    );
  }

}