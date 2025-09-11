import 'dart:convert';

List<RegistroItemRespModel> listRegistroItemRespModelFromJson(String str) =>
    List<RegistroItemRespModel>.from(
        json.decode(str).map((x) => RegistroItemRespModel.fromJson(x)));

RegistroItemRespModel registroItemRespModelFromJson(String str) =>
    RegistroItemRespModel.fromJson(json.decode(str));

String registroItemRespModelToJson(RegistroItemRespModel data) =>
    json.encode(data.toJson());

class RegistroItemRespModel {
  RegistroItemRespModel({
    required this.indice,
    required this.rut,
    required this.codigo,
    required this.vendedor,
    required this.fila,
    required this.articulo,
    required this.cantidad,
    required this.neto,
    required this.descuento,
    required this.ila,
    required this.carne,
    required this.iva,
    required this.precio,
    required this.numeros,
    required this.correlativos,
    required this.pesos,
     this.fecha,
  });

  int indice;
  String rut;
  String codigo;
  String vendedor;
  int fila;
  String articulo;
  double cantidad;
  double neto;
  double descuento;
  double ila;
  double carne;
  double iva;
  double precio;
  String numeros;
  String correlativos;
  String pesos;
  DateTime? fecha;

  factory RegistroItemRespModel.fromJson(Map<String, dynamic> json) =>
      RegistroItemRespModel(
        indice: json["indice"],
        rut: json["rut"],
        codigo: json["codigo"],
        vendedor: json["vendedor"],
        fila: json["fila"],
        articulo: json["articulo"],
        cantidad: json["cantidad"] == null ? 0 : json["cantidad"].toDouble(),
        neto: json["neto"] == null ? 0 : json["neto"].toDouble(),
        descuento: json["descuento"] == null ? 0 : json["descuento"].toDouble(),
        ila: json["ila"] == null ? 0 : json["ila"].toDouble(),
        carne: json["carne"] == null ? 0 : json["carne"].toDouble(),
        iva: json["iva"] == null ? 0 : json["iva"].toDouble(),
        precio: json["precio"] == null ? 0 : json["precio"].toDouble(),
        numeros: json["numeros"],
        correlativos: json["correlativos"],
        pesos: json["pesos"],
        fecha: json["fecha"] == null ? null : DateTime.parse(json["fecha"]),
      );

  Map<String, dynamic> toJson() => {
        "indice": indice,
        "rut": rut,
        "codigo": codigo,
        "vendedor": vendedor,
        "fila": fila,
        "articulo": articulo,
        "cantidad": cantidad,
        "neto": neto,
        "descuento": descuento,
        "ila": ila,
        "carne": carne,
        "iva": iva,
        "precio": precio,
        "numeros": numeros,
        "correlativos": correlativos,
        "pesos": pesos,
        "fecha": fecha == null ? "" : fecha!.toIso8601String(),
      };
}
