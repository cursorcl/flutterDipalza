
import 'dart:convert';

TransmitirModel transmitirModelFromJson(String str) => TransmitirModel.fromJson(json.decode(str));

String transmitirModelToJson(TransmitirModel data) => json.encode(data.toJson());

class TransmitirModel {
    TransmitirModel({
        this.codigo,
    });

    String codigo;

    factory TransmitirModel.fromJson(Map<String, dynamic> json) => TransmitirModel(
        codigo: json["codigo"],
    );

    Map<String, dynamic> toJson() => {
        "codigo": codigo,
    };
}