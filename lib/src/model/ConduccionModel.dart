import 'dart:convert';

List<ConduccionModel> conduccionesModelFromJson(String str) => List<ConduccionModel>.from( json.decode(str).map((x) => ConduccionModel.fromJson(x)));
ConduccionModel conduccionModelFromJson(String str) => ConduccionModel.fromJson(json.decode(str));

String conduccionModelToJson(ConduccionModel data) => json.encode(data.toJson());

class ConduccionModel {
  String codigo;
  String descripcion;
  double valor;


  ConduccionModel({
    required this.codigo,
    required this.descripcion,
    required this.valor
  });
  factory ConduccionModel.fromJson(Map<String, dynamic> json) => ConduccionModel(
    codigo: json["codigo"],
    descripcion: json["descripcion"],
    valor: json["valor"]
  );
  Map<String, dynamic> toJson() => {
    "codigo": codigo,
    "descripcion": descripcion,
    "valor": valor
  };
}