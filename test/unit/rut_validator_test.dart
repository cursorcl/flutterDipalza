import 'package:flutter_test/flutter_test.dart';
import 'package:dipalza_movil/src/validacion/rut_validator.dart';

void main() {
  group('RUTValidator', () {
    group('limpiar', () {
      test('removes points and dashes', () {
        expect(RUTValidator.limpiar('12.345.678-5'), '123456785');
        expect(RUTValidator.limpiar('12.345.678-K'), '12345678K');
        expect(RUTValidator.limpiar('12345678-5'), '123456785');
      });

      test('converts to uppercase', () {
        expect(RUTValidator.limpiar('12.345.678-k'), '12345678K');
      });

      test('keeps only numbers and k/K', () {
        expect(RUTValidator.limpiar('12.345.678-5abc'), '123456785');
      });
    });

    group('formatear', () {
      test('formats valid RUT with DV', () {
        expect(RUTValidator.formatear('123456785'), '12.345.678-5');
        expect(RUTValidator.formatear('12345678K'), '12.345.678-K');
      });

      test('formats already cleaned RUT', () {
        expect(RUTValidator.formatear('12345678K'), '12.345.678-K');
      });
    });

    group('validar', () {
      test('rejects invalid RUTs', () {
        expect(RUTValidator.validar(''), false);
        expect(RUTValidator.validar('abc'), false);
      });
    });

    group('calcularDV', () {
      test('calculates correct digit', () {
        expect(RUTValidator.calcularDV(12345678), '5');
        expect(RUTValidator.calcularDV(11111111), '1');
      });
    });
  });
}
