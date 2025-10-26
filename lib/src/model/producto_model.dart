import 'dart:convert';
import 'package:dipalza_movil/src/model/venta_detalle_item_model.dart';
import 'package:dipalza_movil/src/model/registro_item_resp_model.dart';

List<ProductosModel> productosModelFromJson(String str) => List<ProductosModel>.from( json.decode(str).map((x) => ProductosModel.fromJson(x)));
// EOS Decodificador de string tipo JSON a ProductsModel
// ProductosModel productoModelFromJson(String str) => json.decode(str).map((x) => ProductosModel.fromJson(x));
ProductosModel productoModelFromJson(String str) => ProductosModel.fromJson(json.decode(str));

String productoModelToJson(ProductosModel data) => json.encode(data.toJson());

String productosModelToJson(List<ProductosModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductosModel {
  ProductosModel(
      {
        required this.articulo,
        required this.descripcion,
        required this.ventaneto,
        required this.porcila,
        required this.porccarne,
        required this.unidad,
        required this.stock,
        required this.pieces,
        required this.numbered,
        this.registroItem,
        this.registroItemResp
      }
      );

  String articulo;
  String descripcion;
  double ventaneto;
  double porcila;
  double porccarne;
  String unidad;
  double stock;
  double pieces;
  bool numbered;
  VentaDetalleItemModel? registroItem;
  RegistroItemRespModel? registroItemResp;

  factory ProductosModel.fromJson(Map<String, dynamic> json) => ProductosModel(
        articulo: json["articulo"],
        descripcion: json["descripcion"],
        ventaneto: json["ventaNeto"] == null ? 0 : json["ventaNeto"].toDouble(),
        porcila: json["porcIla"] == null ? 0 : json["porcIla"].toDouble(),
        porccarne: json["porcCarne"] == null ? 0 : json["porcCarne"].toDouble(),
        // unidad: unidadValues.map[json["unidad"].toUpperCase()],
        unidad: json["unidad"].toUpperCase(),
        stock: json["stock"] == null ? 0 : json["stock"].toDouble(),
        pieces: json["pieces"] == null ? 0 : json["pieces"].toDouble(),
        numbered: json["numbered"] == null ? false : json["numbered"],
      );

  Map<String, dynamic> toJson() => {
        "articulo": articulo,
        "descripcion": descripcion,
        "ventaNeto": ventaneto,
        "porcIla": porcila,
        "porcCarne": porccarne,
        // "unidad": unidadValues.reverse[unidad],
        "unidad": unidad,
        "stock": stock,
        "pieces": pieces,
        "numbered": numbered,
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
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
