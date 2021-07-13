import 'dart:convert';

RegistroItemModel registroItemModelFromJson(String str) =>
    RegistroItemModel.fromJson(json.decode(str));

String registroItemModelToJson(RegistroItemModel data) =>
    json.encode(data.toJson());

class RegistroItemModel {
  RegistroItemModel(
      {this.indice,
      this.fila,
      this.rut,
      this.codigo,
      this.vendedor,
      this.articulo,
      this.cantidad,
      this.descuento,
      this.esnumerado,
      this.sobrestock,
      this.fecha,
      this.condicionventa});

  int indice;
  int fila;
  String rut;
  String codigo;
  String vendedor;
  String articulo;
  int cantidad;
  double descuento;
  bool esnumerado;
  bool sobrestock;
  String fecha;
  String condicionventa;

  factory RegistroItemModel.fromJson(Map<String, dynamic> json) =>
      RegistroItemModel(
        indice: json["indice"],
        fila: json["fila"],
        rut: json["rut"],
        codigo: json["codigo"],
        vendedor: json["vendedor"],
        articulo: json["articulo"],
        cantidad: json["cantidad"],
        descuento: json["descuento"],
        esnumerado: json["esnumerado"],
        sobrestock: json["sobrestock"],
        fecha: json["fecha"],
        condicionventa: json["condicionventa"],
      );

  Map<String, dynamic> toJson() => {
        "indice": indice,
        "fila": fila,
        "rut": rut,
        "codigo": codigo,
        "vendedor": vendedor,
        "articulo": articulo,
        "cantidad": cantidad,
        "descuento": descuento,
        "esnumerado": esnumerado,
        "sobrestock": sobrestock,
        "fecha": fecha,
        "condicionventa": condicionventa,
      };
}
