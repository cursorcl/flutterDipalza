import 'venta_model.dart';

class ResumenVentas {
  const ResumenVentas({
    required this.cantidadVentas,
    required this.totalNeto,
    required this.totalDescuento,
    required this.totalIva,
    required this.totalIla,
    required this.totalBruto,
  });

  final int cantidadVentas;
  final double totalNeto;
  final double totalDescuento;
  final double totalIva;
  final double totalIla;
  final double totalBruto;
}

class ResumenVentasCalculator {
  static ResumenVentas calcular(List<VentaModel> ventas) {
    return ResumenVentas(
      cantidadVentas: ventas.length,
      totalNeto: ventas.fold(0.0, (suma, venta) => suma + venta.totalNeto),
      totalDescuento:
          ventas.fold(0.0, (suma, venta) => suma + venta.totalDescuento),
      totalIva: ventas.fold(0.0, (suma, venta) => suma + venta.totalIva),
      totalIla: ventas.fold(0.0, (suma, venta) => suma + venta.totalIla),
      totalBruto: ventas.fold(0.0, (suma, venta) => suma + venta.total),
    );
  }
}
