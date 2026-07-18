import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/app.formatter.dart';
import 'package:dipalza_movil/src/share/app.navigator.dart';
import 'package:dipalza_movil/src/share/app_routes.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../share/app_scaffold_key.dart';

class UltimasVentasClientePage extends StatefulWidget {
  const UltimasVentasClientePage({Key? key}) : super(key: key);

  @override
  _UltimasVentasClientePageState createState() =>
      _UltimasVentasClientePageState();
}

class _UltimasVentasClientePageState extends State<UltimasVentasClientePage> {
  ClientesModel? _cliente;
  Future<List<VentaModel>>? _ventasFuture;

  @override
  void initState() {
    super.initState();
    _seleccionarCliente();
  }

  Future<void> _seleccionarCliente() async {
    final cliente = await AppNavigator.pushNamed<ClientesModel>(
        AppRoutes.clientesSeleccion);
    if (cliente == null) return;
    setState(() {
      _cliente = cliente;
      _ventasFuture =
          VentaProvider.ventaProvider.obtenerUltimasVentasDeCliente(cliente);
    });
  }

  void _reintentar() {
    if (_cliente == null) return;
    setState(() {
      _ventasFuture = VentaProvider.ventaProvider
          .obtenerUltimasVentasDeCliente(_cliente!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            AppScaffoldKey.homeKey.currentState?.openDrawer();
          },
        ),
        centerTitle: true,
        backgroundColor: colorRojoBase(),
        title: Text(
          _cliente == null ? 'Últimas Ventas' : _cliente!.razon,
          style: const TextStyle(color: Colors.white),
        ),
        actions: _cliente == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.person_search),
                  tooltip: 'Cambiar cliente',
                  onPressed: _seleccionarCliente,
                ),
              ],
      ),
      body: _cliente == null ? _creaSinCliente() : _creaConCliente(),
    );
  }

  Widget _creaSinCliente() {
    return Center(
      child: ElevatedButton(
        onPressed: _seleccionarCliente,
        child: const Text('Seleccionar Cliente'),
      ),
    );
  }

  Widget _creaConCliente() {
    return FutureBuilder<List<VentaModel>>(
      future: _ventasFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<VentaModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 10),
                const Text('Ocurrió un error al cargar:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: _reintentar,
                  child: const Text('Reintentar'),
                )
              ],
            ),
          );
        }
        final ventas = snapshot.data ?? [];
        if (ventas.isEmpty) {
          return const Center(
            child: Text('Este cliente no tiene ventas facturadas.'),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(12.0),
          children: ventas.map((venta) => _tarjetaVenta(venta)).toList(),
        );
      },
    );
  }

  Widget _tarjetaVenta(VentaModel venta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => AppNavigator.pushNamed(AppRoutes.listadoUltimaVenta,
            arguments: {'ventaModel': venta}),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 8),
                  Text(
                    AppFormatters.formatoFecha.format(venta.fecha),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Divider(),
              _filaMonto('Neto', venta.totalNeto),
              _filaMonto('IVA', venta.totalIva),
              _filaMonto('ILA', venta.totalIla),
              _filaMonto('Descuento', venta.totalDescuento),
              _filaMonto('Total', venta.total, destacado: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaMonto(String etiqueta, double valor, {bool destacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(etiqueta,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const Spacer(),
          Text(
            AppFormatters.formatoMoneda.format(valor),
            style: TextStyle(
              fontSize: destacado ? 16 : 14,
              fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
