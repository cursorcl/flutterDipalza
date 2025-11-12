import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'login_validacion.dart';

class LoginBloc with Validators {
  final _usuarioController = BehaviorSubject<String>.seeded('');
  final _passwordController = BehaviorSubject<String>.seeded('');
  final _rutaController = BehaviorSubject<String>.seeded('');

  Stream<String> get usuarioStream => _usuarioController.stream.transform(validarUsuario).distinct();
  Stream<String> get passwordStream => _passwordController.stream.transform(validarPassword).distinct();
  Stream<String> get rutaStream => _rutaController.stream.transform(validarRuta).distinct();

  Stream<bool> get formValidStream => Rx.combineLatest3( usuarioStream, passwordStream, rutaStream, (a, b, c) => true );

  Function(String) get changeUsuario => _usuarioController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeRuta => _rutaController.sink.add;

  String get usuario => _usuarioController.value;
  String get password => _passwordController.value;
  String get ruta => _rutaController.value;

  dispose() {
    _usuarioController.close();
    _passwordController.close();
    _rutaController.close();
  }
}
