import 'dart:io';

import 'package:dipalza_movil/src/bloc/login_bloc.dart';
import 'package:dipalza_movil/src/bloc/productos_bloc.dart';
import 'package:dipalza_movil/src/model/login_response_model.dart';
import 'package:dipalza_movil/src/model/respuesta_model.dart';
import 'package:dipalza_movil/src/model/rutas_model.dart';
import 'package:dipalza_movil/src/provider/login_provider.dart';
import 'package:dipalza_movil/src/provider/rutas_provider.dart';
import 'package:dipalza_movil/src/provider/vendedor_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:dipalza_movil/src/widget/version_widget.dart';
import 'package:flutter/material.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart' as alertUtil;

import '../../validacion/rut_validator.dart';
import '../rutas/rutas.page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _textUsuario;
  late TextEditingController _textPassword;
  bool _blockBotton = true;
  final vendedorProvider = new VenderdorProvider();
  final prefs = new PreferenciasUsuario();
  RutasModel? _rutaSeleccionada;
  List<RutasModel> _listaRutas = [];
  final scaffoldKey = new GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _getListaRutas();
    _textUsuario = new TextEditingController(text: prefs.rut);
    _textPassword = new TextEditingController(text: prefs.password);
    super.initState();
  }

  void onChangedApplyFormat(String text, LoginBloc bloc) {
    _textUsuario.text = RUTValidator.formatear(_textUsuario.text);
    bloc.changeUsuario(_textUsuario.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
    bloc.changeUsuario(_textUsuario.text);
    bloc.changePassword(_textPassword.text);

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SafeArea(
            child: Container(
              height: (size.height - (size.height * 0.90)) / 2,
            ),
          ),
          Container(
            width: size.width * 0.90,
            margin: EdgeInsets.symmetric(vertical: 30.0),
            padding: EdgeInsets.symmetric(vertical: 30.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3.0,
                    offset: Offset(0.0, 5.0),
                    spreadRadius: 3.0,
                  ),
                ]),
            child: Column(
              children: <Widget>[
                Hero(
                  tag: 'logo_diplaza',
                  child: Image(
                    image: AssetImage(
                        'assets/image/logo_dipalza_transparente.png'),
                    width: 200.0,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10.0),
                _crearUsuario(context, bloc),
                SizedBox(height: 20.0),
                _crearPassword(context, bloc),
                SizedBox(height: 20.0),
                //_crearComboRutas(context, bloc),
                _crearSelectorRutas(context),
                SizedBox(height: 30.0),
                _crearBoton(bloc, context),
                SizedBox(height: 5.0),
                TextButton(
                    onPressed: () => Navigator.pushNamed(context, 'config'),
                    onLongPress: () =>
                        Navigator.pushReplacementNamed(context, 'consoleLog'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.settings_applications,
                          size: 30.0,
                          color: colorRojoBase(),
                        ),
                        Text('Configurar',
                            style: TextStyle(color: colorRojoBase()))
                      ],
                    )),
                TextButton(
                    onPressed: () => exit(0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.exit_to_app,
                          size: 20.0,
                          color: colorRojoBase(),
                        ),
                        Text('Salir',
                            style: TextStyle(color: colorRojoBase()))
                      ],
                    )),
                SizedBox(height: 15.0),
                VersionWidget(),
              ],
            ),
          ),
          SizedBox(
            height: 50.0,
          )
        ],
      ),
    );
  }

  Widget _crearUsuario(BuildContext context, LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.usuarioStream,
      initialData: '', // doble seguro, aunque ya use seeded
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final String? errorText =
            snapshot.hasError ? snapshot.error?.toString() : null;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: _textUsuario,
            keyboardType: TextInputType.text,
            enabled: _blockBotton,
            decoration: InputDecoration(
              icon: Icon(
                Icons.account_circle,
                color: colorRojoBase(),
              ),
              labelStyle: TextStyle(color: colorRojoBase()),
              labelText: 'Vendedor',
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorRojoBase())),
              // counterText: snapshot.data,
              errorText: errorText,
            ),
            onChanged: (newValue) => this.onChangedApplyFormat(newValue, bloc),
          ),
        );
      },
    );
  }

  Widget _crearPassword(BuildContext context, LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.passwordStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final String? errorText =
            snapshot.hasError ? snapshot.error?.toString() : null;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: _textPassword,
            obscureText: true,
            enabled: _blockBotton,
            decoration: InputDecoration(
              icon: Icon(
                Icons.lock,
                color: colorRojoBase(),
              ),
              labelStyle: TextStyle(color: colorRojoBase()),
              labelText: 'Contraseña',
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorRojoBase())),
              // counterText: snapshot.data,
              errorText: errorText,
            ),
            onChanged: bloc.changePassword,
          ),
        );
      },
    );
  }

  Future<Null> _getListaRutas() async {
    _listaRutas = await RutasProvider.rutasProvider.obtenerListaRutas();
    setState(() {});
  }

  List<DropdownMenuItem<RutasModel>> getOpcionesDropDown() {
    List<DropdownMenuItem<RutasModel>> lista = [];

    _listaRutas.forEach((ruta) {
      lista.add(DropdownMenuItem(
        child: Text(ruta.descripcion),
        value: ruta,
      ));
    });

    return lista;
  }

  Widget _crearComboRutas(BuildContext context, LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.rutaStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final String? errorText =
            snapshot.hasError ? snapshot.error?.toString() : null;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              icon: Icon(
                Icons.show_chart,
                color: colorRojoBase(),
              ),
              labelStyle: TextStyle(color: colorRojoBase()),
              labelText: 'Ruta',
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorRojoBase())),
              errorText: errorText,
            ),
            value: _rutaSeleccionada,
            items: getOpcionesDropDown(),
            onChanged: (opt) {
              setState(() {
                _rutaSeleccionada = opt as RutasModel;
                if (_rutaSeleccionada != null)
                  bloc.changeRuta(_rutaSeleccionada!.codigo);
              });
            },
          ),
        );
      },
    );
  }

  Widget _crearBoton(LoginBloc bloc, BuildContext context) {
    return StreamBuilder(
      stream: bloc.formValidStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return ElevatedButton(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
            child: Text(
              'Ingresar',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: colorRojoBase(),
            elevation: 0.0,
            textStyle: TextStyle(color: Colors.white),
          ),
          onPressed: snapshot.hasData && _blockBotton
              ? () => _login(bloc, context)
              : null,
        );
      },
    );
  }

  _login(LoginBloc bloc, BuildContext context) async {
    // final prefs = new PreferenciasUsuario();
    alertUtil.showBlock(context, '');
    setState(() {
      _blockBotton = false;
    });

    RespuestaModel resp =
        await vendedorProvider.loginUsuario(bloc.usuario, bloc.password);

    if (resp.status == 200) {
      LoginResponseModel response = loginResponseModelFromJson(resp.detalle);
      prefs.vendedor = response.codigo;
      prefs.name = response.nombre;
      prefs.rut = bloc.usuario;
      prefs.password = bloc.password;
      prefs.token = response.accessToken;
      if (_rutaSeleccionada != null) prefs.ruta = _rutaSeleccionada!.codigo;
      ProductosBloc();

      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() {
        _blockBotton = true;
      });
      Navigator.of(context).pop();

      alertUtil.showAlert(
          context,
          'Problemas con el servicio de autenticación (${resp.detalle})',
          Icons.error);
    }
  }

  void mostrarSnackbar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 2500),
    );
    if (scaffoldKey.currentState != null)
      scaffoldKey.currentState!.showSnackBar(snackbar);
    //ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

// Este es el widget que reemplazará tu _crearComboRutas
  Widget _crearSelectorRutas(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ruta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                // Navega a la nueva pantalla y espera el resultado
                final rutaSeleccionada = await Navigator.push<RutasModel>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RutasPage(listaRutas: _listaRutas),
                  ),
                );

                // Si se seleccionó una ruta, actualiza el estado
                if (rutaSeleccionada != null) {
                  setState(() {
                    _rutaSeleccionada = rutaSeleccionada;
                    // Llama al bloc para actualizar el estado
                    final bloc = LoginProvider.of(context);
                    bloc.changeRuta(_rutaSeleccionada!.codigo);
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _rutaSeleccionada?.descripcion ?? 'Seleccione una ruta',
                        style: TextStyle(
                          fontSize: 16,
                          color: _rutaSeleccionada == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
