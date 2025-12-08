import 'dart:convert';

List<NumeradoModel> numeradosModelFromJson(String str) => List<NumeradoModel>.from(json.decode(str).map((x) => NumeradoModel.fromJson(x)));

NumeradoModel numeradoModelFromJson(String str) => NumeradoModel.fromJson(json.decode(str));

String numeradosModelToJson(List<NumeradoModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

String numeradoModelToJson(NumeradoModel data) => json.encode(data.toJson());

class NumeradoModel {
  int id;
  String articulo;
  int numero;
  double peso;
  String estado;
  DateTime creadoEn;
  DateTime actualizadoEn;

  NumeradoModel({
    required this.id,
    required this.articulo,
    required this.numero,
    required this.peso,
    required this.estado,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory NumeradoModel.fromJson(Map<String, dynamic> json) => NumeradoModel(
        id: json["id"],
        articulo: json["articulo"],
        numero: json["numero"],
        peso: json["peso"],
        estado: json["estado"],
        creadoEn: DateTime.parse(json["creadoEn"]),
        actualizadoEn: DateTime.parse(json["actualizadoEn"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "articulo": articulo,
        "numero": numero,
        "peso": peso,
        "estado": estado,
        "creadoEn": creadoEn.toIso8601String(),
        "actualizadoEn": actualizadoEn.toIso8601String(),
      };

  NumeradoModel clone() {
    final String jsonString = json.encode(this);
    final jsonResponse = json.decode(jsonString);
    return NumeradoModel.fromJson(jsonResponse as Map<String, dynamic>);
  }

  static List<NumeradoModel> listFromJson(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((x) => NumeradoModel.fromJson(x)).toList();
  }
}
