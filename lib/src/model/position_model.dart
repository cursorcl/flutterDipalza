import 'dart:convert';

PositionModel positionModelFromJson(String str) => PositionModel.fromJson(json.decode(str));

String positionModelToJson(PositionModel data) => json.encode(data.toJson());

class PositionModel {
    PositionModel({
        this.vendedor,
        this.fecha,
        this.latitude,
        this.longitude,
        this.velocidad,
    });

    String vendedor;
    DateTime fecha;
    double latitude;
    double longitude;
    double velocidad;

    factory PositionModel.fromJson(Map<String, dynamic> json) => PositionModel(
        vendedor: json["vendedor"],
        fecha: DateTime.parse(json["fecha"]),
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        velocidad: json["velocidad"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "vendedor": vendedor,
        "fecha": fecha.toIso8601String(),
        "latitude": latitude,
        "longitude": longitude,
        "velocidad": velocidad,
    };
}