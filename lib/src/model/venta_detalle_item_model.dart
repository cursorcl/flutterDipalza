import 'dart:convert';


List<VentaDetalleItemModel> listVentaDetalleItemModel(String str) =>
    List<VentaDetalleItemModel>.from(
        json.decode(str).map((x) => VentaDetalleItemModel.fromJson(x)));

VentaDetalleItemModel ventaDetalleItemModelFromJson(String str) => VentaDetalleItemModel.fromJson(json.decode(str));

String ventaDetalleItemModelToJson(VentaDetalleItemModel data) => json.encode(data.toJson());

class VentaDetalleItemModel {
  VentaDetalleItemModel(
      {
        required this.ventaId,
        required this.linea,
        required this.productoId,
        required this.nombreProducto,
        required this.cantidad,
        required this.precioUnitario,
        required this.porcDescuento,
        required this.porcIva,
        required this.porcIla,
        required this.neto,
        required this.descuento,
        required this.iva,
        required this.ila,
        required this.totalLinea,
        required this.piezas,
        required this.unidad});

  int ventaId;
  int linea;
  String productoId;
  String nombreProducto;
  double cantidad;
  double precioUnitario;
  double porcDescuento;
  double porcIva;
  double porcIla;
  double neto;
  double descuento;
  double iva;
  double ila;
  double totalLinea;
  int piezas;
  String unidad;

  factory VentaDetalleItemModel.fromJson(Map<String, dynamic> json) => VentaDetalleItemModel(
        ventaId: json["ventaId"],
        linea: json["linea"],
    productoId: json["productoId"],
        nombreProducto: json["nombreProducto"],
        cantidad: json["cantidad"],
         precioUnitario: json["precioUnitario"],
        porcDescuento: json["porcDescuento"],
        porcIva: json["porcIva"],
        porcIla: json["porcIla"],
        neto: json["neto"],
        descuento: json["descuento"],
        iva: json["iva"],
        ila: json["ila"],
        totalLinea: json["totalLinea"],
        piezas: json["piezas"],
        unidad: json["unidad"] == null ? '' : json["unidad"],
      );

  Map<String, dynamic> toJson() => {
        "ventaId": ventaId,
        "linea": linea,
        "productoId": productoId,
        "nombreProducto": nombreProducto,
        "cantidad": cantidad,
        "precioUnitario": precioUnitario,
        "porcDescuento": porcDescuento,
        "porcIva": porcIva,
        "porcIla": porcIla,
        "neto": neto,
        "descuento": descuento,
        "iva": iva,
        "ila": ila,
        "totalLinea": totalLinea,
        "piezas": piezas,
        "unidad": unidad
      };
}
