import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  static final PreferenciasUsuario _instancia = PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  SharedPreferences _prefs;

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  get vendedor {
    return _prefs.getString('vendedor') ?? '';
  }

  set vendedor(String value) {
    _prefs.setString('vendedor', value);
  }

  get name {
    return _prefs.getString('name') ?? '';
  }

  set name(String value) {
    _prefs.setString('name', value);
  }

  get rut {
    return _prefs.getString('rut') ?? '';
  }

  set rut(String value) {
    _prefs.setString('rut', value);
  }

  get password {
    return _prefs.getString('password') ?? '';
  }

  set password(String value) {
    _prefs.setString('password', value);
  }

  get token {
    return _prefs.getString('token') ?? '';
  }

  set token(String value) {
    _prefs.setString('token', value);
  }

  get urlServicio {
    return _prefs.getString('urlServicio') ?? '';
  }

  set urlServicio(String value) {
    _prefs.setString('urlServicio', value);
  }

  get ruta {
    return _prefs.getString('ruta') ?? '';
  }

  set ruta(String value) {
    _prefs.setString('ruta', value);
  }

  get reporte {
    return _prefs.getInt('reporte') ?? 300000;
  }

  set reporte(int value) {
    _prefs.setInt('reporte', value);
  }
}
