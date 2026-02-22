import 'dart:convert';

List<RutasModel> rutasModelFromJson(String str) =>
    List<RutasModel>.from(json.decode(str).map((x) => RutasModel.fromJson(x)));

String rutasModelToJson(List<RutasModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RutasModel {
  RutasModel(
      {required this.codigo,
      required this.descripcion,
      required this.codigoConduccion,
      required this.nombreConduccion});

  String codigo;
  String descripcion;
  String codigoConduccion;
  String nombreConduccion;

  factory RutasModel.fromJson(Map<String, dynamic> json) => RutasModel(
      codigo: json["codigo"],
      descripcion: json["descripcion"],
      codigoConduccion: json['codigoConduccion'],
      nombreConduccion: json['nombreConduccion']);

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
        "codigoConduccion": codigoConduccion,
        "nombreConduccion": nombreConduccion
      };
}
