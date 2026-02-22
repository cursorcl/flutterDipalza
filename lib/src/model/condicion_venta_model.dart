import 'dart:convert';

List<CondicionVentaModel> condicionVentasModelFromJson(String str) => List<CondicionVentaModel>.from( json.decode(str).map((x) => CondicionVentaModel.fromJson(x)));
CondicionVentaModel condicionVentaModelFromJson(String str) => CondicionVentaModel.fromJson(json.decode(str));

String condicionVentaModelToJson(CondicionVentaModel data) => json.encode(data.toJson());

class CondicionVentaModel {
    String codigo;
    String descripcion;
    int dias;

    CondicionVentaModel({
        required this.codigo,
        required this.descripcion,
        required this.dias

    });
    factory CondicionVentaModel.fromJson(Map<String, dynamic> json) => CondicionVentaModel(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
        dias: json["dias"]
    );
    Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
        "dias": dias
    };
}