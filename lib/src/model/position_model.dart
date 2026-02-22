import 'dart:convert';

PositionModel positionModelFromJson(String str) => PositionModel.fromJson(json.decode(str));

String positionModelToJson(PositionModel data) => json.encode(data.toJson());

class PositionModel {
    PositionModel({
        this.vendedor,
        this.fecha,
        this.latitude,
        this.longitude,
    });

    String? vendedor;
    DateTime? fecha;
    double? latitude;
    double? longitude;

    factory PositionModel.fromJson(Map<String, dynamic> json) => PositionModel(
        vendedor: json["vendedor"],
        fecha: DateTime.parse(json["fecha"]),
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
    );
    Map<String, dynamic> toJson() => {
        "vendedor": vendedor,
        "fecha": fecha == null ? DateTime.now().toIso8601String() : fecha!.toIso8601String(),
        "latitude": latitude,
        "longitude": longitude,
    };
}