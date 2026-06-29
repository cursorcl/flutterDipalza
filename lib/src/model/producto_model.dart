import 'dart:convert';

import 'package:dipalza_movil/src/model/numerado_model.dart';

List<ProductosModel> productosModelFromJson(String str) =>
    List<ProductosModel>.from(
        json.decode(str).map((x) => ProductosModel.fromJson(x)));

ProductosModel productoModelFromJson(String str) =>
    ProductosModel.fromJson(json.decode(str));

String productoModelToJson(ProductosModel data) => json.encode(data.toJson());

String productosModelToJson(List<ProductosModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductosModel {
  ProductosModel(
      {required this.articulo,
      required this.descripcion,
      required this.ventaneto,
      required this.precioLista2,
      required this.porcila,
      required this.porccarne,
      required this.unidad,
      required this.stock,
      required this.numbered,
      required this.codigoila,
      required this.pieces,
      required this.stockVentas,
      required this.piezasVentas,
      required this.numerados});

  String articulo;
  String descripcion;
  double ventaneto;
  double precioLista2;
  double porcila;
  double porccarne;
  String unidad;
  double stock;
  bool numbered;
  String codigoila;
  double pieces;
  double stockVentas;
  double piezasVentas;
  List<NumeradoModel> numerados;

  factory ProductosModel.fromJson(Map<String, dynamic> json) => ProductosModel(
      articulo: json["articulo"],
      descripcion: json["descripcion"],
      ventaneto: json["ventaNeto"] == null ? 0 : json["ventaNeto"].toDouble(),
      precioLista2: json["precioLista2"] == null ? 0 : json["precioLista2"].toDouble(),
      porcila: json["porcIla"] == null ? 0 : json["porcIla"].toDouble(),
      porccarne: json["porcCarne"] == null ? 0 : json["porcCarne"].toDouble(),
      unidad: json["unidad"].toUpperCase(),
      stock: json["stock"] == null ? 0 : json["stock"].toDouble(),
      numbered: json["numbered"] == null ? false : json["numbered"],
      numerados: NumeradoModel.listFromJson(json["numerados"]),
      codigoila: json["codigoila"] ?? "",
      pieces: json["pieces"] == null ? 0 : json["pieces"],
      stockVentas: json["stockVentas"] == null ? 0 : json["stockVentas"],
      piezasVentas: json["piezasVentas"] == null ? 0 : json["piezasVentas"]);

  Map<String, dynamic> toJson() => {
        "articulo": articulo,
        "descripcion": descripcion,
        "ventaNeto": ventaneto,
        "precioLista2": precioLista2,
        "porcIla": porcila,
        "porcCarne": porccarne,
        "unidad": unidad,
        "stock": stock,
        "numbered": numbered,
        "numerados": numeradosModelToJson(numerados),
        "codigoila": codigoila,
        "pieces": pieces,
        "stockVentas": stockVentas,
        "piezasVentas": piezasVentas
      };

  ProductosModel clone() {
    final String jsonString = json.encode(this);
    final jsonResponse = json.decode(jsonString);
    return ProductosModel.fromJson(jsonResponse as Map<String, dynamic>);
  }
}

enum Unidad {
  UNI,
  CAJ,
  EMPTY,
  DIS,
  UNIDAD_UNI,
  UN,
  KIL,
  BOL,
  UNIDAD_CAJ,
  PAC,
  UNIDAD_KIL,
  LT,
  BID,
  KI,
  CAL
}

final unidadValues = EnumValues({
  "BID": Unidad.BID,
  "BOL": Unidad.BOL,
  "CAJ": Unidad.CAJ,
  "CAL": Unidad.CAL,
  "DIS": Unidad.DIS,
  "": Unidad.EMPTY,
  "KI": Unidad.KI,
  "KIL": Unidad.KIL,
  "LT": Unidad.LT,
  "PAC": Unidad.PAC,
  "UN": Unidad.UN,
  "UNI": Unidad.UNI
});

final unidadValuesDetalle = EnumValues({
  "Bidón": Unidad.BID,
  "Bolsa": Unidad.BOL,
  "Caja": Unidad.CAJ,
  "CAL": Unidad.CAL,
  "DIS": Unidad.DIS,
  "": Unidad.EMPTY,
  "KI": Unidad.KI,
  "Kilo": Unidad.KIL,
  "Litro": Unidad.LT,
  "PAC": Unidad.PAC,
  "UN": Unidad.UN,
  "Unidad": Unidad.UNI
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => new MapEntry(v, k));
    return reverseMap;
  }
}
