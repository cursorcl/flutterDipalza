import 'dart:convert';

import 'package:dipalza_movil/src/model/venta_detalle_pieza_model.dart';

List<VentaDetalleModel> listVentaDetalleModel(String str) => List<VentaDetalleModel>.from(json.decode(str).map((x) => VentaDetalleModel.fromJson(x)));

VentaDetalleModel ventaDetalleModelFromJson(String str) => VentaDetalleModel.fromJson(json.decode(str));

String ventaDetalleModelToJson(VentaDetalleModel data) => json.encode(data.toJson());

class VentaDetalleModel {
  VentaDetalleModel(
      {this.id = -1,
      required this.ventaId,
      required this.idProducto,
      required this.nombreProducto,
      required this.cantidad,
      required this.precioUnitario,
      required this.porcentajeDescuento,
      required this.porcentajeIva,
      required this.porcentajeIla,
      required this.totalLinea,
      required this.totalDescuento,
      required this.totalIva,
      required this.totalIla,
      required this.piezas,
      required this.unidad,
      this.piezasDetalle = const []});

  int id;
  int ventaId;
  String idProducto;
  String nombreProducto;
  double cantidad;
  double precioUnitario;
  double porcentajeDescuento;
  double porcentajeIva;
  double porcentajeIla;
  double totalLinea;
  double totalIla;
  double totalIva;
  double totalDescuento;
  String unidad;
  int piezas;
  List<VentaDetallePiezaModel> piezasDetalle;

  factory VentaDetalleModel.fromJson(Map<String, dynamic> json) => VentaDetalleModel(
        id: json['id'],
        ventaId: json["ventaId"],
        idProducto: json["idProducto"],
        nombreProducto: json["nombreProducto"] ?? "",
        cantidad: json["cantidad"],
        precioUnitario: json["precioUnitario"],
        porcentajeDescuento: json["porcentajeDescuento"],
        porcentajeIva: json["porcentajeIva"],
        porcentajeIla: json["porcentajeIla"],
        totalLinea: json["totalLinea"],
        totalIla: json["totalIla"],
        totalIva: json["totalIva"],
        totalDescuento: json["totalDescuento"],
        unidad: json["unidad"] == null ? '' : json["unidad"],
        piezas: json["piezas"],
        piezasDetalle: (json['piezasDetalle'] as List?)?.map((e) => VentaDetallePiezaModel.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ventaId": ventaId,
        "idProducto": idProducto,
        "nombreProducto": nombreProducto,
        "cantidad": cantidad,
        "precioUnitario": precioUnitario,
        "porcentajeDescuento": porcentajeDescuento,
        "porcentajeIva": porcentajeIva,
        "porcentajeIla": porcentajeIla,
        "totalLinea": totalLinea,
        "totalIla": totalIla,
        "totalIva": totalIva,
        "totalDescuento": totalDescuento,
        "piezas": piezas,
        "unidad": unidad,
        'piezasDetalle': piezasDetalle.map((d) => d.toJson()).toList(),
      };
}
