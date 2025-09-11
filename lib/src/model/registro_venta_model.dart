import 'dart:convert';

RegistroVentaModel registroVentaModelFromJson(String str) => RegistroVentaModel.fromJson(json.decode(str));

String registroVentaModelToJson(RegistroVentaModel data) => json.encode(data.toJson());

class RegistroVentaModel {
    RegistroVentaModel({
        required this.rut,
        required this.codigo,
        required this.vendedor,
        required this.condicionVenta,
        required this.fecha,
    });

    String rut;
    String codigo;
    String vendedor;
    String condicionVenta;
    DateTime fecha;

    factory RegistroVentaModel.fromJson(Map<String, dynamic> json) => RegistroVentaModel(
        rut: json["rut"],
        codigo: json["codigo"],
        vendedor: json["vendedor"],
        condicionVenta: json["condicion_venta"],
        fecha: DateTime.parse(json["fecha"]),
    );

    Map<String, dynamic> toJson() => {
        "rut": rut,
        "codigo": codigo,
        "vendedor": vendedor,
        "condicion_venta": condicionVenta,
        "fecha": fecha.toIso8601String(),
    };
}
