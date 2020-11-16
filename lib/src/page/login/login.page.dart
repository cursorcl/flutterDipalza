import 'package:dipalza_movil/src/bloc/login_bloc.dart';
import 'package:dipalza_movil/src/model/respuesta_model.dart';
import 'package:dipalza_movil/src/provider/login_provider.dart';
import 'package:dipalza_movil/src/provider/vendedor_provider.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:dipalza_movil/src/widget/version_widget.dart';
import 'package:flutter/material.dart';
import 'package:dipalza_movil/src/utils/alert_util.dart' as alertUtil;

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _textUsuario;
  TextEditingController _textPassword;
  bool _blockBotton = true;
  final vendedorProvider = new VenderdorProvider();
  final prefs = new PreferenciasUsuario();

  @override
  void initState() {
    super.initState();
    _textUsuario = new TextEditingController(text: prefs.usuario);
    _textPassword = new TextEditingController(text: prefs.password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FondoWidget(),
          // _crearColorFondo2(context),
          // _crearIconosFondo(context),
          _loginForm(context),
        ],
      ),
    );
  }

  // Widget _crearColorFondo(BuildContext context) {
  //   return Container(
  //     height: double.infinity,
  //     width: double.infinity,
  //     color: Theme.of(context).primaryColor,
  //   );
  // }

  // Widget _crearColorFondo2(BuildContext context) {
  //   final size = MediaQuery.of(context).size;

  //   final _fondo = Container(
  //     height: size.height * 0.4,
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //         gradient: LinearGradient(colors: [
  //       Theme.of(context).primaryColorDark,
  //       Theme.of(context).primaryColorLight
  //     ])),
  //   );

  //   return Stack(
  //     children: <Widget>[
  //       _fondo,
  //       Container(
  //         padding: EdgeInsets.only(top: 80.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: <Widget>[
  //             Hero(
  //               tag: 'logo_diplaza',
  //               child: Image(
  //                 image:
  //                     AssetImage('assets/image/logo_dipalza_transparente.png'),
  //                 width: 200.0,
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //             SizedBox(
  //               height: 1.0,
  //               width: double.infinity,
  //             )
  //           ],
  //         ),
  //       )
  //     ],
  //   );
  // }

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
              height: 80.0,
            ),
          ),
          Container(
            width: size.width * 0.75,
            // height: size.height * 0.5,
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
                // Text('Ingreso' , style: TextStyle(fontSize: 20.0),),
                Hero(
                tag: 'logo_diplaza',
                child: Image(
                  image:
                      AssetImage('assets/image/logo_dipalza_transparente.png'),
                  width: 200.0,
                  fit: BoxFit.cover,
                ),
              ),
                SizedBox(height: 10.0),
                _crearUsuario(context, bloc),
                SizedBox(height: 20.0),
                _crearPassword(context, bloc),
                SizedBox(height: 30.0),
                _crearBoton(bloc, context),
                SizedBox(height: 5.0),
                FlatButton(onPressed: () {}, child: Text('¿Olvidó su Clave?', style: TextStyle(color: colorRojoBase()),)),
                FlatButton(onPressed: () => Navigator.pushNamed(context, 'config'), child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.settings_applications, size: 30.0, color: colorRojoBase(),),
                    Text('Configurar', style: TextStyle(color: colorRojoBase()))
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
      builder: (BuildContext context, AsyncSnapshot snapshot) {
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
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorRojoBase())),
              // counterText: snapshot.data,
              errorText: snapshot.error,
            ),
            onChanged: (newValue) => bloc.changeUsuario(newValue),
          ),
        );
      },
    );
  }

  Widget _crearPassword(BuildContext context, LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.passwordStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
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
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorRojoBase())),
              // counterText: snapshot.data,
              errorText: snapshot.error,
            ),
            onChanged: bloc.changePassword,
          ),
        );
      },
    );
  }

  Widget _crearBoton(LoginBloc bloc, BuildContext context) {
    return StreamBuilder(
      stream: bloc.formValidStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return RaisedButton(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
            child: Text('Ingresar', style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 0.0,
          // color: Theme.of(context).primaryColor,
          color: colorRojoBase(),
          textColor: Colors.white,
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

    RespuestaModel resp = await vendedorProvider.loginUsuario(bloc.usuario, bloc.password);
    print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    print(resp);

    // if (resp.status == 200) {
    //   // UsuarioModel user = usuarioModelFromJson(resp.detalle);
    //   // prefs.nombreUsuario = user.name;
    //   // prefs.email = user.email;
    //   // prefs.organizacion = user.organizacion;
    //   prefs.usuario = bloc.usuario;
    //   prefs.password = bloc.password;

    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, '/');
    // } else {
    //   setState(() {
    //     _blockBotton = true;
    //   });
    //   Navigator.of(context).pop();

    //   alertUtil.showAlert(context, resp.detalle, Icons.error);
    // }
  }
}
