import 'dart:convert';

List<ConfiguracionModel> configuracionModelFromJson(String str) => List<ConfiguracionModel>.from(json.decode(str).map((x) => ConfiguracionModel.fromJson(x)));

String configuracionModelToJson(List<ConfiguracionModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConfiguracionModel {
    ConfiguracionModel({
        required this.clave,
        required this.valor,
    });

    String clave;
    String valor;

    factory ConfiguracionModel.fromJson(Map<String, dynamic> json) => ConfiguracionModel(
        clave: json["clave"],
        valor: json["valor"],
    );

    Map<String, dynamic> toJson() => {
        "clave": clave,
        "valor": valor,
    };
}