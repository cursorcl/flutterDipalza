import 'dart:convert';

List<LogModel> logModelFromJson(String str) => List<LogModel>.from(json.decode(str).map((x) => LogModel.fromJson(x)));

String logModelToJson(List<LogModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LogModel {
    int id;
    String tipo;
    String log;

    LogModel({
        required this.id,
        required this.tipo,
        required this.log,
    });

    factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        id: json["id"],
        tipo: json["tipo"],
        log: json["log"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "tipo": tipo,
        "log": log,
    };
}