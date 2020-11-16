import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'login_validacion.dart';

class LoginBloc with Validators {

  final _usuarioController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  Stream<String> get usuarioStream => _usuarioController.stream.transform(validarUsuario);
  Stream<String>  get passwordStream => _passwordController.stream.transform(validarPassword);
  Stream<bool> get formValidStream => Rx.combineLatest2(usuarioStream, passwordStream, (e, p) => true);

  Function(String) get changeUsuario => _usuarioController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  String get usuario => _usuarioController.value;
  String get password => _passwordController.value;

  dispose() {
    _usuarioController?.close();
    _passwordController?.close();
  }

}