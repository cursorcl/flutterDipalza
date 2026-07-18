import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../share/prefs_usuario.dart';
import '../../utils/utils.dart';
import '../login/auth_gate.dart';

/// Se muestra solo cuando 'urlServicio' está vacío (primera vez que corre
/// la app en el dispositivo, o después de borrar sus datos). Sin esto, la
/// app caía silenciosamente a un servidor por defecto ('ventas.dynalias.net')
/// sin que el usuario lo supiera.
class ServerSetupPage extends StatefulWidget {
  const ServerSetupPage({super.key});

  @override
  State<ServerSetupPage> createState() => _ServerSetupPageState();
}

class _ServerSetupPageState extends State<ServerSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String _aFormatoAlmacenado(String input) {
    var t = input.trim();
    t = t.replaceAll(RegExp(r'^https?://', caseSensitive: false), '');
    t = t.replaceAll(RegExp(r'/+$'), '');
    return t;
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;

    final prefs = PreferenciasUsuario();
    prefs.urlServicio = _aFormatoAlmacenado(_urlController.text);
    ApiClient().dio.options.baseUrl = 'http://${prefs.urlServicio}';

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.dns_outlined, size: 64, color: colorRojoBase()),
                  const SizedBox(height: 16),
                  const Text(
                    'Configura el servidor',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingresa la dirección del servidor antes de continuar '
                    '(por ejemplo: localhost:8080 o ventas.dynalias.net:8080).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _urlController,
                    autofocus: true,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _continuar(),
                    decoration: const InputDecoration(
                      labelText: 'Servidor',
                      hintText: 'host:puerto',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa la dirección del servidor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _continuar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorRojoBase(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
