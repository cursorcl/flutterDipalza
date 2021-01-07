import 'dart:convert';

import 'clientes_model.dart';

List<VentaModel> ventaModelFromJson(String str) => List<VentaModel>.from(json.decode(str).map((x) => VentaModel.fromJson(x)));

String ventaModelToJson(List<VentaModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VentaModel {
    VentaModel({
        this.rut,
        this.razon,
        this.codigo,
        this.fecha,
        this.neto,
        this.descuento,
        this.totalila,
        this.carne,
        this.iva,
        this.cliente,
    });

    String rut;
    String razon;
    String codigo;
    DateTime fecha;
    double neto;
    double descuento;
    double totalila;
    double carne;
    double iva;
    ClientesModel cliente;

    factory VentaModel.fromJson(Map<String, dynamic> json) => VentaModel(
        rut: json["rut"],
        codigo: json["codigo"],
        fecha: DateTime.parse(json["fecha"]),
        neto: json["neto"].toDouble(),
        descuento: json["descuento"].toDouble(),
        totalila: json["totalila"] == null ? 0 : json["totalila"].toDouble(),
        carne: json["carne"].toDouble(),
        iva: json["iva"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "rut": rut,
        "codigo": codigo,
        "fecha": fecha,
        "neto": neto,
        "descuento": descuento,
        "totalila": totalila,
        "carne": carne,
        "iva": iva,
    };
}
