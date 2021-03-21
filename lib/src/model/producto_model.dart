import 'dart:convert';
import 'package:dipalza_movil/src/model/registro_item_model.dart';
import 'package:dipalza_movil/src/model/registro_item_resp_model.dart';

List<ProductosModel> productosModelFromJson(String str) =>
    List<ProductosModel>.from(
        json.decode(str).map((x) => ProductosModel.fromJson(x)));
// EOS Decodificador de string tipo JSON a ProductsModel
// ProductosModel productoModelFromJson(String str) => json.decode(str).map((x) => ProductosModel.fromJson(x));
ProductosModel productoModelFromJson(String str) =>
    ProductosModel.fromJson(json.decode(str));

String productosModelToJson(List<ProductosModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductosModel {
  ProductosModel(
      {this.articulo,
      this.descripcion,
      this.ventaneto,
      this.porcila,
      this.porccarne,
      this.unidad,
      this.stock,
      this.pieces,
      this.numbered,
      this.registroItem,
      this.registroItemResp});

  String articulo;
  String descripcion;
  int ventaneto;
  double porcila;
  double porccarne;
  String unidad;
  double stock;
  double pieces;
  bool numbered;
  RegistroItemModel registroItem;
  RegistroItemRespModel registroItemResp;

  factory ProductosModel.fromJson(Map<String, dynamic> json) => ProductosModel(
        articulo: json["Articulo"],
        descripcion: json["Descripcion"],
        ventaneto: json["VentaNeto"] == null ? 0 : json["VentaNeto"].toInt(),
        porcila: json["PorcIla"] == null ? 0 : json["PorcIla"].toDouble(),
        porccarne: json["PorcCarne"] == null ? 0 : json["PorcCarne"].toDouble(),
        // unidad: unidadValues.map[json["unidad"].toUpperCase()],
        unidad: json["Unidad"].toUpperCase(),
        stock: json["Stock"] == null ? 0 : json["Stock"].toDouble(),
        pieces: json["Pieces"] == null ? 0 : json["Pieces"].toDouble(),
        numbered: json["Numbered"],
      );

  Map<String, dynamic> toJson() => {
        "Articulo": articulo,
        "Descripcion": descripcion,
        "VentaNeto": ventaneto,
        "PorcIla": porcila,
        "PorcCarne": porccarne,
        // "unidad": unidadValues.reverse[unidad],
        "Unidad": unidad,
        "Stock": stock,
        "Pieces": pieces,
        "Numbered": numbered,
      };
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
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
