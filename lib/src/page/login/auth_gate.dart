import 'package:flutter/material.dart';
import '../../share/prefs_usuario.dart';
import '../home/home.page.dart';
import 'login.page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = PreferenciasUsuario();
    setState(() {
      isLoggedIn = prefs.token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return isLoggedIn!
        ? HomePage()
        : LoginPage();
  }
}
