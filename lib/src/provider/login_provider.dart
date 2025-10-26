import 'package:dipalza_movil/src/bloc/login_bloc.dart';
import 'package:flutter/material.dart';

class LoginProvider extends InheritedWidget {
  final loginBloc = LoginBloc();
  static LoginProvider? _instancia;

  factory LoginProvider({Key? key, required Widget child}) {
      _instancia ??= new LoginProvider._internal(key: key, child: child);

    return _instancia!;
  }

  LoginProvider._internal({Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static LoginBloc of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<LoginProvider>();
    return provider!.loginBloc;
  }
}
