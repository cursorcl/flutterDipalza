import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/provider/venta_provider.dart';
import 'package:dipalza_movil/src/share/app_routes.dart';
import 'package:dipalza_movil/src/utils/utils.dart'; // Para colorRojoBase() y getFormatRut()
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/condicion_venta_model.dart';
import '../../model/venta_model.dart';
import '../../provider/cliente_provider.dart';
import '../../provider/condicion_venta_provider.dart';
import '../../share/app.navigator.dart';
import '../../share/estado.venta.dart';
import '../../share/prefs_usuario.dart';
import '../../widget/fondo.widget.dart';

class VentaEncabezadoEdicionPage extends StatefulWidget {
  final VentaModel? ventaEnEdicion;

  const VentaEncabezadoEdicionPage({Key? key, this.ventaEnEdicion})
      : super(key: key);

  @override
  _VentaEncabezadoEdicionPageState createState() =>
      _VentaEncabezadoEdicionPageState();
}

class _VentaEncabezadoEdicionPageState
    extends State<VentaEncabezadoEdicionPage> {
  VentaModel? ventaParaEditar;
  PreferenciasUsuario pref = PreferenciasUsuario();
  bool _estaCargando = false;
  ClientesModel? _clienteSeleccionado;
  List<CondicionVentaModel> _listaCondicionesVenta = [];
  CondicionVentaModel? _condicionSeleccionada;
  late final DateTime _fechaFacturacion;

  @override
  void initState() {
    super.initState();
    ventaParaEditar = widget.ventaEnEdicion;
    _cargarDatosIniciales();
    _fechaFacturacion = pref.fechaFacturacion;
  }

  /// Navega a tu ClientesPage y espera un resultado
  void _navegarASeleccionCliente(BuildContext context) async {
    final cliente = await AppNavigator.pushNamed(AppRoutes.clientesSeleccion);
    // Cuando vuelve (con Navigator.of(context).pop), actualizamos el estado
    if (cliente != null && cliente is ClientesModel) {
      setState(() {
        _clienteSeleccionado = cliente;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter =
        DateFormat('dd \'de\' MMMM \'de\' yyyy', 'es_ES');
    final String fechaFormateada = formatter.format(_fechaFacturacion);

    return Scaffold(
        appBar: AppBar(
          title: Text(ventaParaEditar == null || ventaParaEditar?.id == -1
              ? 'Nueva Venta'
              : 'Venta #${ventaParaEditar?.id}'),
          backgroundColor: colorRojoBase(), // Usando tu color
        ),
        body: Stack(children: <Widget>[
          const Positioned.fill(
            child: FondoWidget(),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Fecha de Facturación',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                        ),
                  ),
                  Text(
                    fechaFormateada,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildClienteSelector(context),
                  const SizedBox(height: 16),
                  _buildCondicionVentaModelSelector(),
                  const Spacer(), // Empuja el botón al fondo
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Detalle Venta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorRojoBase(), // Usando tu color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: (_clienteSeleccionado == null)
                        ? null // Deshabilita el botón si no hay cliente
                        : () async {
                            try {
                              await saveVenta();
                              if (!mounted) return;
                              AppNavigator.pushNamed(AppRoutes.ventaDetalle,
                                  arguments: {
                                    'ventaModel': ventaParaEditar,
                                    'esEdicion': true
                                  });
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al guardar la venta: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
          )
        ]));
  }

  Widget _buildClienteSelector(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          _navegarASeleccionCliente(context);
        },
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(Icons.person, color: colorRojoBase()),
          title: Text(
            _clienteSeleccionado?.razon ?? 'Seleccionar Cliente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: _clienteSeleccionado == null
                  ? FontWeight.normal
                  : FontWeight.bold,
              color: _clienteSeleccionado == null
                  ? Colors.grey[700]
                  : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _clienteSeleccionado?.rut != null
                ? getFormatRut(_clienteSeleccionado!.rut) // Usando tu función
                : 'Toca para buscar por nombre o código',
          ),
          trailing: const Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildCondicionVentaModelSelector() {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonFormField<CondicionVentaModel>(
          value: _condicionSeleccionada,
          // Quita el subrayado
          decoration: const InputDecoration(
              border: InputBorder.none, labelText: 'Método de Pago'),
          isExpanded: true,
          items: _listaCondicionesVenta.map((CondicionVentaModel metodo) {
            return DropdownMenuItem<CondicionVentaModel>(
              value: metodo,
              child: Text(metodo.descripcion),
            );
          }).toList(),
          onChanged: (CondicionVentaModel? newValue) {
            setState(() {
              _condicionSeleccionada = newValue;
            });
          },
        ),
      ),
    );
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _estaCargando = true);

    try {
      _listaCondicionesVenta = await CondicionVentaProvider
          .condicionVentaProvider
          .obtenerListaCondicionVenta();
      if (ventaParaEditar != null) {
        _cargarDatosParaEdicion();
      } else {
        if (_listaCondicionesVenta.isNotEmpty) {
          _condicionSeleccionada = _listaCondicionesVenta.first;
        }
      }
    } catch (e) {
      print('Error al cargar datos iniciales: $e');
      // (Aquí deberías mostrar un snackbar o alerta de error)
    }

    setState(() => _estaCargando = false);
  }

  void _cargarDatosParaEdicion() async {
    setState(() => _estaCargando = true);

    final venta = ventaParaEditar!;

    try {
      final cliente = await ClientesProvider.clientesProvider
          .obtenerClienteByRutCodigo(venta.rutCliente, venta.codigoCliente);

      final condicion = _listaCondicionesVenta.firstWhere(
          (c) => c.codigo == venta.codigoCondicionVenta,
          orElse: () => _listaCondicionesVenta.first);
      setState(() {
        _clienteSeleccionado = cliente;
        _condicionSeleccionada = condicion;
        _estaCargando = false;
      });
    } catch (e) {
      print('Error al cargar datos para edición: $e');
      setState(() => _estaCargando = false);
    }
  }

  Future<VentaModel> saveVenta() async {
    VentaModel ventaModel = VentaModel(
        id: ventaParaEditar?.id ?? -1,
        fecha: _fechaFacturacion,
        rutCliente: _clienteSeleccionado!.rut,
        codigoCliente: _clienteSeleccionado!.codigo,
        codigoVendedor: pref.vendedor,
        tipoVendedor: pref.tipo,
        codigoRuta: pref.ruta,
        codigoCondicionVenta: _condicionSeleccionada!.codigo,
        detalles: ventaParaEditar?.detalles ?? [],
        estadoVenta: EstadoVenta.OPENED);

    final VentaModel ventaGuardada =
        await VentaProvider.ventaProvider.saveVentaEncabezado(ventaModel);
    if (mounted) setState(() {
      ventaParaEditar = ventaGuardada;
    });
    return ventaGuardada;
  }
}
