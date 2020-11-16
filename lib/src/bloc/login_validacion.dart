import 'dart:async';

class Validators {
  final validarUsuario = StreamTransformer<String, String>.fromHandlers(
      handleData: (usuario, sink) {
    if (usuario.length >= 3) {
      sink.add(usuario);
    } else {
      sink.addError('El usuario minimo 3 caracteres.');
    }
  });

  final validarPassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (password.length >= 6) {
      sink.add(password);
    } else {
      sink.addError('La contraseña debe mayor a 6 caracteres.');
    }
  });

   final validarRuta = StreamTransformer<String, String>.fromHandlers(
      handleData: (ruta, sink) {
    if (ruta.length >= 0) {
      sink.add(ruta);
    } else {
      sink.addError('Debe seleccionar Ruta.');
    }
  });

}
