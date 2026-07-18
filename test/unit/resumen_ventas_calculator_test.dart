import 'package:flutter_test/flutter_test.dart';
import 'package:dipalza_movil/src/model/venta_model.dart';
import 'package:dipalza_movil/src/model/resumen_ventas_calculator.dart';

VentaModel _buildVenta({
  double totalNeto = 0,
  double totalDescuento = 0,
  double totalIva = 0,
  double totalIla = 0,
  double total = 0,
}) {
  return VentaModel(
    fecha: DateTime(2026, 7, 17),
    rutCliente: '11111111-1',
    codigoVendedor: 'V1',
    codigoRuta: 'R1',
    codigoCondicionVenta: 'CT',
    totalNeto: totalNeto,
    totalDescuento: totalDescuento,
    totalIva: totalIva,
    totalIla: totalIla,
    total: total,
  );
}

void main() {
  group('ResumenVentasCalculator', () {
    test('calcula cero con lista vacía', () {
      final resumen = ResumenVentasCalculator.calcular([]);

      expect(resumen.cantidadVentas, 0);
      expect(resumen.totalNeto, 0);
      expect(resumen.totalDescuento, 0);
      expect(resumen.totalIva, 0);
      expect(resumen.totalIla, 0);
      expect(resumen.totalBruto, 0);
    });

    test('suma los totales de varias ventas', () {
      final ventas = [
        _buildVenta(
            totalNeto: 1000,
            totalDescuento: 100,
            totalIva: 190,
            totalIla: 50,
            total: 1140),
        _buildVenta(
            totalNeto: 2000,
            totalDescuento: 0,
            totalIva: 380,
            totalIla: 100,
            total: 2480),
      ];

      final resumen = ResumenVentasCalculator.calcular(ventas);

      expect(resumen.cantidadVentas, 2);
      expect(resumen.totalNeto, 3000);
      expect(resumen.totalDescuento, 100);
      expect(resumen.totalIva, 570);
      expect(resumen.totalIla, 150);
      expect(resumen.totalBruto, 3620);
    });

    test('cuenta correctamente una sola venta', () {
      final resumen = ResumenVentasCalculator.calcular([
        _buildVenta(totalNeto: 500, total: 500),
      ]);

      expect(resumen.cantidadVentas, 1);
      expect(resumen.totalNeto, 500);
      expect(resumen.totalBruto, 500);
    });
  });
}
