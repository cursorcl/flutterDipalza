import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'login_validacion.dart';

class LoginBloc with Validators {
  final _usuarioController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _rutaController = BehaviorSubject<String>();

  Stream<String> get usuarioStream =>
      _usuarioController.stream.transform(validarUsuario);
  Stream<String> get passwordStream =>
      _passwordController.stream.transform(validarPassword);
  Stream<String> get rutaStream =>
      _rutaController.stream.transform(validarRuta);

  // Stream<bool> get formValidStream => Rx.combineLatest2(usuarioStream, passwordStream, (e, p) => true);
  Stream<bool> get formValidStream => Rx.combineLatest3(
      usuarioStream, passwordStream, rutaStream, (a, b, c) => true);

  Function(String) get changeUsuario => _usuarioController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeRuta => _rutaController.sink.add;

  String get usuario => _usuarioController.value;
  String get password => _passwordController.value;
  String get ruta => _rutaController.value;

  dispose() {
    _usuarioController?.close();
    _passwordController?.close();
    _rutaController?.close();
  }
}
