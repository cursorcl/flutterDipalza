import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  static final PreferenciasUsuario _instancia = PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  late SharedPreferences _prefs;

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get vendedor {
    return _prefs.getString('vendedor') ?? '';
  }

  set vendedor(String value) {
    _prefs.setString('vendedor', value);
  }

  String get name {
    return _prefs.getString('name') ?? "";
  }

  set name(String value) {
    _prefs.setString('name', value);
  }

  String get rut {
    return _prefs.getString('rut') ?? '';
  }

  set rut(String value) {
    _prefs.setString('rut', value);
  }

  String get password {
    return _prefs.getString('password') ?? '';
  }

  set password(String value) {
    _prefs.setString('password', value);
  }

  String get token {
    return _prefs.getString('token') ?? '';
  }

  set token(String value) {
    _prefs.setString('token', value);
  }

  String get urlServicio {
    return _prefs.getString('urlServicio') ?? '';
  }

  set urlServicio(String value) {
    _prefs.setString('urlServicio', value);
  }

  String get ruta {
    return _prefs.getString('ruta') ?? '';
  }

  set ruta(String value) {
    _prefs.setString('ruta', value);
  }

  int get reporte {
    return _prefs.getInt('reporte') ?? 300000;
  }

  set reporte(int value) {
    _prefs.setInt('reporte', value);
  }
}
