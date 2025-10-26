import 'dart:io';

import 'package:dipalza_movil/src/bloc/login_bloc.dart';
import 'package:dipalza_movil/src/model/rutas_model.dart';
import 'package:dipalza_movil/src/provider/login_provider.dart';
import 'package:dipalza_movil/src/provider/vendedor_provider.dart';
import 'package:dipalza_movil/src/services/connectivity_service.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart' as alertUtil;
import 'package:intl/intl.dart'; // <-- NUEVO: Importar paquete de formato
import 'package:provider/provider.dart';
import '../../validacion/rut_validator.dart';
import 'package:dipalza_movil/src/model/login_response_model.dart';
import 'package:dipalza_movil/src/model/respuesta_model.dart';

import '../../widget/fondo.widget.dart';
import '../../widget/version_widget.dart';
import '../rutas/rutas.page.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _textUsuarioController;
  late TextEditingController _textPasswordController;

  final vendedorProvider = VenderdorProvider();
  final prefs = PreferenciasUsuario();
  RutasModel? _rutaSeleccionada;

  // --- NUEVO: Variable de estado para la fecha ---
  DateTime? _fechaFacturacion;

  bool _isLoading = false;
  bool _obscureText = true;
  ServerStatus status = ServerStatus.connecting;

  @override
  void initState() {
    super.initState();
    _textUsuarioController = TextEditingController(text: prefs.rut);
    _textPasswordController = TextEditingController(text: prefs.password);

    // --- NUEVO: Establecer la fecha de facturación por defecto a mañana ---
    _fechaFacturacion = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _textUsuarioController.dispose();
    _textPasswordController.dispose();
    super.dispose();
  }

  void _onRutChanged(String text, LoginBloc bloc) {
    _textUsuarioController.text = RUTValidator.formatear(text);
    _textUsuarioController.selection = TextSelection.fromPosition(TextPosition(offset: _textUsuarioController.text.length));
    bloc.changeUsuario(_textUsuarioController.text);
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = context.watch<ConnectivityService>();
    this.status = connectivityService.status;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FondoWidget(),
          _loginForm(context),

        ],
      ),
    );
  }

  Widget _loginForm(BuildContext context) {
    final bloc = LoginProvider.of(context);
    final size = MediaQuery.of(context).size;

    bloc.changeUsuario(_textUsuarioController.text);
    bloc.changePassword(_textPasswordController.text);

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: size.width * 0.90,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 5.0),
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/image/logo_dipalza_transparente.png',
                width: 180.0,
              ),
              const SizedBox(height: 30.0),
              AbsorbPointer(
                absorbing: status != ServerStatus.online,
                child: _crearUsuario(bloc),
              ),

              const SizedBox(height: 20.0),
              AbsorbPointer(
                  absorbing: status != ServerStatus.online,
                  child: _crearPassword(bloc),
              ),
              const SizedBox(height: 20.0),
              AbsorbPointer(
                absorbing: status != ServerStatus.online,
                child: _crearSelectorRutas(context, bloc),
              ),
              const SizedBox(height: 20.0),

              AbsorbPointer(
                absorbing: status != ServerStatus.online,
                child: _crearSelectorFechaFacturacion(context),
              ),
              const SizedBox(height: 30.0),
              AbsorbPointer(
                absorbing: status != ServerStatus.online,
                child: _crearBotonIngresar(bloc),
              ),
              const SizedBox(height: 15.0),

              _crearBotonesSecundarios(context),
              const SizedBox(height: 20.0),

              const Divider(),
              const SizedBox(height: 10.0),

              _buildServerStatusIndicator(),
              const SizedBox(height: 15.0),

              VersionWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // ... (los widgets _crearUsuario y _crearPassword se mantienen igual) ...
  Widget _crearUsuario(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.usuarioStream,
      builder: (context, snapshot) {
        return TextField(
          controller: _textUsuarioController,
          keyboardType: TextInputType.text,
          enabled: !_isLoading,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person_outline, color: colorRojoBase()),
            labelText: 'Vendedor',
            errorText: snapshot.hasError ? snapshot.error.toString() : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (value) => _onRutChanged(value, bloc),
        );
      },
    );
  }

  Widget _crearPassword(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.passwordStream,
      builder: (context, snapshot) {
        return TextField(
          controller: _textPasswordController,
          obscureText: _obscureText,
          enabled: !_isLoading,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: colorRojoBase()),
            labelText: 'Contraseña',
            errorText: snapshot.hasError ? snapshot.error.toString() : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: IconButton(
              icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
          ),
          onChanged: bloc.changePassword,
        );
      },
    );
  }

  Widget _crearSelectorRutas(BuildContext context, LoginBloc bloc) {
    return InkWell(
      onTap: _isLoading ? null : () async {
        final List<RutasModel> listaRutas = []; // TODO: Cargar la lista de rutas
        final rutaSeleccionada = await Navigator.push<RutasModel>(
          context,
          MaterialPageRoute(builder: (context) => RutasPage()), //RutasPage(listaRutas: listaRutas)),
        );
        if (rutaSeleccionada != null) {
          setState(() => _rutaSeleccionada = rutaSeleccionada);
          bloc.changeRuta(_rutaSeleccionada!.codigo);
        }
      },
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Icon(Icons.map_outlined, color: colorRojoBase()),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _rutaSeleccionada?.descripcion ?? 'Seleccione una ruta',
                style: TextStyle(
                  fontSize: 16,
                  color: _rutaSeleccionada == null ? Colors.grey[700] : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- NUEVO: Widget completo para el selector de fecha ---
  Widget _crearSelectorFechaFacturacion(BuildContext context) {
    // Formateamos la fecha para mostrarla. Ej: "15/09/2025"
    final String fechaFormateada = _fechaFacturacion != null
        ? DateFormat('dd/MM/yyyy').format(_fechaFacturacion!)
        : 'Seleccione fecha';

    return InkWell(
      onTap: _isLoading ? null : () => _selectDate(context),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: colorRojoBase()),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Facturación: $fechaFormateada',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 24, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- NUEVO: Lógica para mostrar el DatePicker ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      // La fecha inicial del picker será la que ya está seleccionada
      initialDate: _fechaFacturacion ?? DateTime.now(),
      // Permitimos seleccionar desde hoy...
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      // ...hasta un año en el futuro.
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    // Si el usuario seleccionó una fecha (no canceló)
    if (picked != null && picked != _fechaFacturacion) {
      setState(() {
        _fechaFacturacion = picked;
      });
      // Opcional: Si quieres, puedes notificar al BLoC sobre el cambio
      // final bloc = LoginProvider.of(context);
      // bloc.changeFechaFacturacion(picked);
    }
  }


  Widget _crearBotonIngresar(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.formValidStream,
      builder: (context, snapshot) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: _isLoading ? Container() : const Icon(Icons.login, color: Colors.white),
            label: _isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Ingresar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              backgroundColor: colorRojoBase(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: (snapshot.hasData && !_isLoading) ? () => _login(bloc, context) : null,
          ),
        );
      },
    );
  }

  Widget _crearBotonesSecundarios(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, 'config'),
          child: const Text('Configurar'),
        ),
        TextButton(
          onPressed: () => exit(0),
          child: const Text('Salir'),
        ),
      ],
    );
  }

  Widget _buildServerStatusIndicator() {

    String message;
    Color color;
    IconData icon;

    switch (status) {
      case ServerStatus.online:
        message = 'Servidor: En línea';
        color = Colors.green.shade700;
        icon = Icons.cloud_done_outlined;
        break;
      case ServerStatus.offline:
        message = 'Servidor: Fuera de línea';
        color = Colors.red.shade700;
        icon = Icons.cloud_off_outlined;
        break;
      case ServerStatus.noInternet:
        message = 'Sin conexión a Internet';
        color = Colors.grey.shade600;
        icon = Icons.wifi_off;
        break;
      case ServerStatus.connecting:
      default:
        message = 'Conectando...';
        color = Colors.orange.shade700;
        icon = Icons.cloud_sync_outlined;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20.0),
        const SizedBox(width: 8.0),
        Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _login(LoginBloc bloc, BuildContext context) async {
    setState(() => _isLoading = true);

    RespuestaModel resp = await vendedorProvider.loginUsuario(bloc.usuario, bloc.password);

    if (resp.status == 200 && mounted) {
      LoginResponseModel response = loginResponseModelFromJson(resp.detalle);
      prefs.vendedor = response.codigo;
      prefs.name = response.nombre;
      prefs.rut = bloc.usuario;
      prefs.password = bloc.password;
      prefs.token = response.accessToken;
      if (_rutaSeleccionada != null) prefs.ruta = _rutaSeleccionada!.codigo;

      // Se guarda como String en formato ISO 8601 (estándar y robusto)
      if (_fechaFacturacion != null) {
        prefs.fechaFacturacion = _fechaFacturacion!;
      }

      Navigator.pushReplacementNamed(context, '/');
    } else if (mounted) {
      alertUtil.showAlert(
          context,
          'Problemas con el servicio de autenticación (${resp.detalle})',
          Icons.error);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}