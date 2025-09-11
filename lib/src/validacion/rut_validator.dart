class RUTValidator {
  /// Elimina puntos y guión del RUT.
  static String limpiar(String rut) {
    return rut.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
  }

  /// Formatea un RUT limpio o sin formato: `12345678K` → `12.345.678-K`
  static String formatear(String rut) {
    rut = limpiar(rut);
    if (rut.length < 2) return rut;

    final cuerpo = rut.substring(0, rut.length - 1);
    final dv = rut.substring(rut.length - 1).toUpperCase();

    final buffer = StringBuffer();
    for (int i = 0; i < cuerpo.length; i++) {
      if (i != 0 && (cuerpo.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cuerpo[i]);
    }

    return '${buffer.toString()}-$dv';
  }

  /// Valida el RUT completo (con o sin formato).
  static bool validar(String rut) {
    rut = limpiar(rut);
    if (rut.length < 2) return false;

    final cuerpo = rut.substring(0, rut.length - 1);
    final dv = rut.substring(rut.length - 1).toUpperCase();

    if (!RegExp(r'^\d+$').hasMatch(cuerpo)) return false;

    int suma = 0;
    int multiplo = 2;

    for (int i = cuerpo.length - 1; i >= 0; i--) {
      suma += int.parse(cuerpo[i]) * multiplo;
      multiplo = multiplo == 7 ? 2 : multiplo + 1;
    }

    final resultado = 11 - (suma % 11);
    final dvEsperado = resultado == 11 ? '0' : resultado == 10 ? 'K' : '$resultado';

    return dv == dvEsperado;
  }

  /// Calcula el dígito verificador para un RUT numérico.
  static String calcularDV(int rut) {
    int suma = 0;
    int multiplo = 2;
    final cuerpo = rut.toString();

    for (int i = cuerpo.length - 1; i >= 0; i--) {
      suma += int.parse(cuerpo[i]) * multiplo;
      multiplo = multiplo == 7 ? 2 : multiplo + 1;
    }

    final resultado = 11 - (suma % 11);
    return resultado == 11 ? '0' : resultado == 10 ? 'K' : '$resultado';
  }
}
