import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/utils/utils.dart'; // Para colorRojoBase() y getFormatRut()
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/condicion_venta_model.dart';
import '../../model/venta_model.dart';
import '../../provider/cliente_provider.dart';
import '../../provider/condicion_venta_provider.dart';
import '../../share/prefs_usuario.dart';
import '../cliente/clientes.page.dart';
import 'listaventas.detalle.page.dart';

class PaginaVenta extends StatefulWidget {
  final VentaModel? ventaParaEditar;

  const PaginaVenta({Key? key, this.ventaParaEditar}) : super(key: key);

  @override
  _PaginaVentaState createState() => _PaginaVentaState();
}

class _PaginaVentaState extends State<PaginaVenta> {
  // --- Estado de la página ---
  bool _estaCargando = false;
  ClientesModel? _clienteSeleccionado;
  List<CondicionVentaModel> _listaCondicionesVenta = [];
  CondicionVentaModel? _condicionSeleccionada;
  final DateTime _fechaFacturacion = DateTime.now();


  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  /// Navega a tu ClientesPage y espera un resultado
  void _navegarASeleccionCliente(BuildContext context) async {

    // Aquí ocurre la magia: llamas a tu ClientesPage
    final cliente = await Navigator.push(
      context,
      MaterialPageRoute(
        // Le decimos a tu página que la queremos para "Seleccionar"
        builder: (context) => const ClientesPage(isForSelection: true),
      ),
    );

    // Cuando vuelve (con Navigator.pop), actualizamos el estado
    if (cliente != null && cliente is ClientesModel) {
      setState(() {
        _clienteSeleccionado = cliente;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formateador de fecha
    // Asegúrate de tener 'package:intl' y configurar el locale
    final DateFormat formatter = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'es_ES');
    final String fechaFormateada = formatter.format(_fechaFacturacion);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta'),
        backgroundColor: colorRojoBase(), // Usando tu color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Fecha de Facturación ---
            Text(
              'Fecha de Facturación',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              fechaFormateada,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // --- 2. Selector de Cliente ---
            _buildClienteSelector(context),

            const SizedBox(height: 16),

            // --- 3. Selector de Método de Pago ---
            _buildCondicionVentaModelSelector(),

            const Spacer(), // Empuja el botón al fondo

            // --- 4. Botón de Acción ---
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continuar a Detalle Venta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorRojoBase(), // Usando tu color
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: (_clienteSeleccionado == null)
                  ? null // Deshabilita el botón si no hay cliente
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget.ventaParaEditar == null ? ListaVentasDetallePage() : ListaVentasDetallePage(ventaId: widget
                        .ventaParaEditar!.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Un widget que parece un campo de formulario pero que navega al tocarlo
  Widget _buildClienteSelector(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          _navegarASeleccionCliente(context);
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(Icons.person, color: colorRojoBase()),
          title: Text(
            _clienteSeleccionado?.razon ?? 'Seleccionar Cliente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: _clienteSeleccionado == null ? FontWeight.normal : FontWeight.bold,
              color: _clienteSeleccionado == null ? Colors.grey[700] : Colors.black,
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

  /// Un Dropdown estándar para los métodos de pago
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
              border: InputBorder.none,
              labelText: 'Método de Pago'
          ),
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

  /// Carga todos los datos necesarios para la página
  Future<void> _cargarDatosIniciales() async {
    setState(() => _estaCargando = true);

    try {
      _listaCondicionesVenta = await CondicionVentaProvider.condicionVentaProvider.obtenerListaCondicionVenta();
      if (widget.ventaParaEditar != null) {
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

    final venta = widget.ventaParaEditar!;
    final prefs = new PreferenciasUsuario();

    try {
      final cliente = await ClientesProvider.clientesProvider
          .obtenerClienteByRutCodigo( venta.clienteRut, venta.clienteCodigo);

      final condicion =_listaCondicionesVenta.firstWhere(
              (c) => c.codigo == venta.condicionVentaCodigo,
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
}