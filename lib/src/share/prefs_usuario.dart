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

  List<String> get recentEndpoints {
    return _prefs.getStringList('serviceHistory') ?? [];
  }

  set recentEndpoints(List<String> value) {
    _prefs.setStringList('serviceHistory', value);
  }

  // --- NUEVO: Getter para fechaFacturacion ---
  DateTime get fechaFacturacion {
    // Leemos el string guardado en SharedPreferences.
    final fechaGuardada = _prefs.getString('fechaFacturacion');

    // Si no hay nada guardado, devolvemos la fecha de mañana como valor por defecto.
    if (fechaGuardada == null) {
      return DateTime.now().add(const Duration(days: 1));
    }

    // Si hay un string, lo convertimos de nuevo a un objeto DateTime.
    // Usamos tryParse para evitar errores si el string estuviera mal formado.
    return DateTime.tryParse(fechaGuardada) ?? DateTime.now().add(const Duration(days: 1));
  }

  // --- NUEVO: Setter para fechaFacturacion ---
  set fechaFacturacion(DateTime value) {
    // Guardamos la fecha convirtiéndola a un string en formato ISO 8601.
    // Este formato ('2025-09-15T10:30:00.000') es estándar y seguro.
    _prefs.setString('fechaFacturacion', value.toIso8601String());
  }


  double get iva {
    return  _prefs.getDouble('iva') ?? 19.0;
  }

  set iva(double value) {
    _prefs.setDouble('iva', value);
  }

}
