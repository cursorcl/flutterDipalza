import 'dart:convert';

import 'clientes_model.dart';
import 'condicion-model.dart';

List<VentaModel> ventaModelFromJson(String str) => List<VentaModel>.from(json.decode(str).map((x) => VentaModel.fromJson(x)));

String ventaModelToJson(List<VentaModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VentaModel {
    VentaModel({
        required this.rut,
        this.razon,
        required this.codigo,
        required this.fecha,
        required this.neto,
        required this.descuento,
        required this.totalila,
        required this.carne,
        required this.iva,
        this.cliente,
        this.condicionventacode,
        this.condicionventa
    });

    String rut;
    String? razon;
    String codigo;
    DateTime fecha;
    double neto;
    double descuento;
    double totalila;
    double carne;
    double iva;
    ClientesModel? cliente;
    String? condicionventacode;
    CondicionVentaModel? condicionventa;

    factory VentaModel.fromJson(Map<String, dynamic> json) => VentaModel(
        rut: json["rut"],
        codigo: json["codigo"],
        fecha: DateTime.parse(json["fecha"]),
        neto: json["neto"] == null ? 0 : json["neto"].toDouble(),
        descuento: json["descuento"] == null ? 0 : json["descuento"].toDouble(),
        totalila: json["totalila"] == null ? 0 : json["totalila"].toDouble(),
        carne: json["carne"] == null ? 0 : json["carne"].toDouble(),
        iva: json["iva"] == null ? 0 : json["iva"].toDouble(),
        condicionventacode: json["condicionventacode"] == null ? "0" : json["condicionventacode"]

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
        "condicionventacode": condicionventacode
    };
}
