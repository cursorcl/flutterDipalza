import 'dart:convert';

import 'clientes_model.dart';
import 'condicion_venta_model.dart';

List<VentaModel> ventaModelFromJson(String str) => List<VentaModel>.from(json.decode(str).map((x) => VentaModel.fromJson(x)));

String ventaModelToJson(List<VentaModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VentaModel {
    VentaModel({
        required this.id,
        required this.fecha,
        required this.clienteRut,
        required this.clienteCodigo,
        required this.clienteNombre,
        required this.condicionVentaCodigo,
        required this.condicionVentaNombre,
        required this.total,
        required this.totalDescuento,
        required this.totalIla,
        required this.totalIva,

    });
    int id;
    String clienteRut;
    String clienteNombre;
    String clienteCodigo;
    DateTime fecha;
    double total;
    double totalDescuento;
    double totalIla;
    double totalIva;
    String condicionVentaCodigo;
    String condicionVentaNombre;

    factory VentaModel.fromJson(Map<String, dynamic> json) => VentaModel(
        id: json["id"] == null ? 0 : json["id"],
        fecha: DateTime.parse(json["fecha"]),
        clienteRut: json["clienteRut"],
        clienteCodigo: json["clienteCodigo"],
        clienteNombre: json["clienteNombre"],
        condicionVentaCodigo: json["condicionVentaCodigo"],
        condicionVentaNombre: json["condicionVentaNombre"],
        total: json["total"].toDouble(),
        totalDescuento: json["totalDescuento"].toDouble(),
        totalIla: json["totalIla"].toDouble(),
        totalIva: json["totalIva"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "fecha": fecha.toIso8601String(),
        "clienteRut": clienteRut,
        "clienteCodigo": clienteCodigo,
        "clienteNombre": clienteNombre,
        "condicionVentaCodigo": condicionVentaCodigo,
        "condicionVentaNombre": condicionVentaNombre,
        "total": total,
        "totalDescuento": totalDescuento,
        "totalIla": totalIla,
        "totalIva": totalIva
    };
}
