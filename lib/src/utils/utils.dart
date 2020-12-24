import 'dart:ui';

import 'package:dart_rut_validator/dart_rut_validator.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

HexColor colorIconHome() {
  return HexColor('#1464f6');
}

HexColor colorRojoBase() {
  return HexColor('#f44336');
}

String getValorModena(double valor, int decimal) {
  FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
      amount: valor,
      settings: MoneyFormatterSettings(
          // symbol: 'IDR',
          thousandSeparator: '.',
          decimalSeparator: ',',
          symbolAndNumberSeparator: ' ',
          fractionDigits: decimal,
          compactFormatType: CompactFormatType.short));

  return fmf.output.symbolOnLeft + '.-';
}

String getValorNumero(double valor) {
  FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
      amount: valor,
      settings: MoneyFormatterSettings(
          symbol: '',
          thousandSeparator: '.',
          decimalSeparator: ',',
          symbolAndNumberSeparator: ' ',
          fractionDigits: 0,
          compactFormatType: CompactFormatType.short));

  return fmf.output.symbolOnLeft + '';
}

String getValorNumeroDecimal(double valor, int decimal) {
  FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
      amount: valor,
      settings: MoneyFormatterSettings(
          symbol: '',
          thousandSeparator: '.',
          decimalSeparator: ',',
          symbolAndNumberSeparator: ' ',
          fractionDigits: decimal,
          compactFormatType: CompactFormatType.short));

  return fmf.output.symbolOnLeft + '';
}

String getFormatRut(String rut) {
  while (rut.startsWith('0')) {
    rut = rut.substring(1, rut.length);
  }
  rut = RUTValidator.formatFromText(rut);
  return rut;
}

String getFormatRutToService(String usuario) {
  String rut = (RUTValidator.getRutNumbers(usuario)).toString() +
      RUTValidator.getRutDV(usuario);
  while (rut.length < 10) {
    rut = '0' + rut;
  }
  return rut;
}
