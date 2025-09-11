import 'dart:convert';

List<CondicionVentaModel> condicionVentasModelFromJson(String str) => List<CondicionVentaModel>.from( json.decode(str).map((x) => CondicionVentaModel.fromJson(x)));
CondicionVentaModel condicionVentaModelFromJson(String str) => CondicionVentaModel.fromJson(json.decode(str));

String loginModelToJson(CondicionVentaModel data) => json.encode(data.toJson());

class CondicionVentaModel {
    CondicionVentaModel({
        required this.codigo,
        required this.descripcion,

    });

    String codigo;
    String descripcion;

    factory CondicionVentaModel.fromJson(Map<String, dynamic> json) => CondicionVentaModel(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
    );

    Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
    };
}