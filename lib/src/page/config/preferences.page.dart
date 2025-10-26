import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../model/rutas_model.dart';
import '../../share/prefs_usuario.dart';
import '../../utils/jwt_util.dart';
import '../../utils/utils.dart';
import '../../widget/connectivity_banner.widget.dart';
import '../rutas/rutas.page.dart';
import 'package:intl/intl.dart';

enum ConnectionStatus { unknown, ok, invalid }

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final _prefs = PreferenciasUsuario();
  late TextEditingController _urlController;
  RutasModel? _rutaSeleccionada;
  DateTime? _fechaTrabajo;
  double? _iva;
  double? _ila;
  late final NumberFormat _pct = NumberFormat.decimalPattern('es_CL');

  ConnectionStatus _status = ConnectionStatus.unknown;
  bool _probando = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _prefs.urlServicio);
    // Estado inicial: si hay URL, no asumimos conectividad hasta probar
    _status = (_prefs.urlServicio.isEmpty)
        ? ConnectionStatus.unknown
        : ConnectionStatus.unknown;
  }

  bool get _canShowLogout {
    if (_prefs.token == null || _prefs.token!.isEmpty) return false;
    // Elige UNA de las dos líneas según tu tipo de token:
    return !isJwtExpired(_prefs.token!);                          // JWT
  }

  Future<void> _logout() async {
     _prefs.token = '';
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Future<void> _pickFechaTrabajo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaTrabajo ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Seleccione fecha de trabajo',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() => _fechaTrabajo = picked);
      _prefs.fechaFacturacion = picked; // mismo setter que usa LoginPage
    }
  }

  Future<void> _pickRuta() async {
    // TODO: reemplace por su carga real de rutas
    final List<RutasModel> listaRutas = [];
    final seleccion = await Navigator.push<RutasModel>(
      context,
      MaterialPageRoute(builder: (context) =>RutasPage()), // RutasPage(listaRutas: listaRutas)),
    );
    if (seleccion != null) {
      setState(() => _rutaSeleccionada = seleccion);
      _prefs.ruta = seleccion.codigo; // mismo setter que usa LoginPage
    }
  }

  // ---------- Normalización y validación ----------

  String? _validateUrl(String input) {
    final t = input;
    if (t.isEmpty) return 'La dirección no puede estar vacía';

    Uri? uri;
    try {
      uri = Uri.parse(t);
    } catch (_) {
      return 'Formato de URL inválido';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'Esquema no admitido (use http o https)';
    }
    if ((uri.host.isEmpty)) {
      return 'Host inválido';
    }
    // Puerto opcional. Si no hay puerto, ok; si hay, que sea válido.
    if (uri.hasPort && (uri.port <= 0 || uri.port > 65535)) {
      return 'Puerto inválido';
    }
    return null; // válido
  }



  /// Quita esquema y trailing slash. Devuelve 'host:puerto'.
  String toStoreFormat(String input) {
    var t = input.trim();
    t = t.replaceAll(RegExp(r'^https?://', caseSensitive: false), '');
    t = t.replaceAll(RegExp(r'/+$'), '');
    return t;
  }

  /// Dado 'host:puerto' devuelve 'http://host:puerto' para UI.
  String toDisplayFormat(String stored) {
    if (stored.isEmpty) return '';
    return 'http://$stored';
  }

  /// Construye la URI real para /health desde 'host:puerto'.
  Uri buildPingUriFromStored(String stored) {
    return Uri.parse('http://$stored').replace(path: '/ping');
  }
  // ---------- Prueba de conexión (HEAD/GET /health o raíz) ----------

  Future<bool> _pingServer(String baseUrl, {Duration timeout = const Duration(seconds: 4)}) async {
    final uri = Uri.parse(baseUrl);

    final u = uri.replace(path: '/ping');

      try {
        final client = HttpClient()..connectionTimeout = timeout;
        final request = await client.getUrl(u).timeout(timeout);
        request.headers.set(HttpHeaders.userAgentHeader, 'DipalzaApp/1.0');
        final response = await request.close().timeout(timeout);
        // Códigos 2xx o 3xx consideramos OK
        if (response.statusCode >= 200 && response.statusCode < 400) {
          client.close(force: true);
          return true;
        }
        client.close(force: true);
      } catch (_) {
        // probar siguiente candidato
      }
    return false;
  }


  String _fmtPct(double v) => '${_pct.format(v)} %';

// Acepta “19”, “19.0” o “19,0” y valida rango 0..100
  String? _validatePct(String? raw) {
    final t = (raw ?? '').trim();
    if (t.isEmpty) return 'Ingrese un valor';
    final val = double.tryParse(t.replaceAll('.', '').replaceAll(',', '.')) ??
        double.tryParse(t);
    if (val == null) return 'Número inválido';
    if (val < 0 || val > 100) return 'Debe estar entre 0 y 100';
    return null;
  }

  double _parsePct(String raw) {
    // ya validado
    return double.parse(raw.trim().replaceAll('.', '').replaceAll(',', '.'));
  }

  Future<void> _editTax({
    required String titulo,
    required double valorActual,
    required ValueChanged<double> onSave,
  }) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: _pct.format(valorActual));
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Ej.: 19 o 19,0',
                    suffixText: '%',
                  ),
                  validator: _validatePct,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final v = _parsePct(controller.text);
                          onSave(v);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$titulo actualizado a ${_fmtPct(v)}')),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // ---------- UI helpers ----------

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (_status) {
      case ConnectionStatus.ok:
        return Colors.green;
      case ConnectionStatus.invalid:
        return Colors.red;
      case ConnectionStatus.unknown:
      default:
        return cs.tertiary; // ámbar/neutral según tema
    }
  }

  IconData _statusIcon() {
    switch (_status) {
      case ConnectionStatus.ok:
        return Icons.check_circle;
      case ConnectionStatus.invalid:
        return Icons.cancel;
      case ConnectionStatus.unknown:
      default:
        return Icons.help;
    }
  }

  String _statusText() {
    switch (_status) {
      case ConnectionStatus.ok:
        return 'Conectado';
      case ConnectionStatus.invalid:
        return 'No disponible';
      case ConnectionStatus.unknown:
      default:
        return 'No verificado';
    }
  }

  Future<void> _copiar() async {
    final text = _prefs.urlServicio;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Dirección copiada')));
  }

  // ---------- Bottom sheet edición ----------

  Future<void> _openEditServerSheet() async {
    final formKey = GlobalKey<FormState>();
    _urlController.text = toDisplayFormat(_prefs.urlServicio);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: viewInsets.bottom + 16,
            top: 8,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dirección del servidor',
                    style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'http://192.168.0.8:8099 o 192.168.0.8:8099',
                    helperText: 'Ejemplo: http://192.168.0.8:8080',
                    prefixIcon: Icon(Icons.dns),
                  ),
                  validator: (v) => _validateUrl(v ?? ''),
                  onFieldSubmitted: (_) => FocusScope.of(ctx).unfocus(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _probando
                            ? null
                            : () async {
                          final error = _validateUrl(_urlController.text);
                          if (error != null) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(error)));
                            return;
                          }
                          setState(() => _probando = true);
                          final ok =
                          await _pingServer(_urlController.text);
                          if (!mounted) return;
                          setState(() {
                            _probando = false;
                            _status =
                            ok ? ConnectionStatus.ok : ConnectionStatus.invalid;
                          });
                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text(ok
                                  ? 'Conexión verificada'
                                  : 'No se pudo conectar')));
                        },
                        icon: _probando
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.wifi_tethering),
                        label: const Text('Probar conexión'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        final error = _validateUrl(_urlController.text);
                        if (error != null) {
                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(ctx)
                              .showSnackBar(SnackBar(content: Text(error)));
                          return;
                        }
                        _prefs.urlServicio = toStoreFormat(_urlController.text);
                        _prefs.recentEndpoints.insert(0, _urlController.text);
                        if (!mounted) return;
                        setState(() {}); // refresca la ficha principal
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dirección guardada')));
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Historial (si implementas getRecentEndpoints)
                Builder(builder: (_) {
                  final recents = _prefs.recentEndpoints;
                  if (recents.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 24),
                      Text('Recientes',
                          style: Theme.of(ctx).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recents.take(6).map((e) {
                          return ActionChip(
                            avatar: const Icon(Icons.history, size: 18),
                            label: Text(e, overflow: TextOverflow.ellipsis),
                            onPressed: () {
                              _urlController.text = e;
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Secciones ----------

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sin botón de volver; título centrado para consistencia
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: const Text('Configuración'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Buscar',
            onPressed: () {
              // TODO: búsqueda de opciones (si aplica)
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        children: [
          // ¡Aquí está! Se mostrará en la parte superior de la pantalla.
          ConnectivityBanner(),
          // -------- Conexión --------
          _sectionHeader('Conexión'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _statusColor(context).withOpacity(0.15),
                child: Icon(_statusIcon(), color: _statusColor(context)),
              ),
              title: const Text('Dirección del servidor'),
              subtitle: Text(
                _prefs.urlServicio.isEmpty
                    ? 'No configurada'
                    : _prefs.urlServicio,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Copiar',
                    onPressed: _prefs.urlServicio.isEmpty ? null : _copiar,
                    icon: const Icon(Icons.copy),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: _openEditServerSheet,
            ),
          ),

          // // -------- Preferencias --------
          _sectionHeader('Preferencias'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                // Ruta
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: const Text('Ruta'),
                  subtitle: Text(
                    _rutaSeleccionada?.descripcion ?? _rutaSeleccionada?.codigo ?? 'Seleccione una ruta',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickRuta,
                ),
                const Divider(height: 0),

                // Fecha de trabajo
                ListTile(
                  leading: const Icon(Icons.today),
                  title: const Text('Fecha de trabajo'),
                  subtitle: Text(
                    _fechaTrabajo != null ? _fmt(_fechaTrabajo!) : 'Seleccione fecha',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _pickFechaTrabajo,
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('IVA'),
                  subtitle: Text(_fmtPct(_prefs.iva)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editTax(
                    titulo: 'IVA',
                    valorActual: _prefs.iva,
                    onSave: (v) => setState(() => _prefs.iva = v),
                  ),
                ),
              ],
            ),
          ),

          // -------- Cuenta --------
          if(_canShowLogout) ...[
          _sectionHeader('Cuenta'),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              final salir = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar'),
                  content: const Text('¿Desea cerrar la sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );
              if (salir == true && mounted) {
                // Limpia tokens/estado y navega a login
                _logout();
              }
            },
          ),
          ],
          // -------- Acerca de --------
          _sectionHeader('Acerca de'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versión'),
            subtitle: Text('1.0.0 (build 1)'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
