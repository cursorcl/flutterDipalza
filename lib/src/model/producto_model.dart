import 'dart:convert';

List<ProductosModel> productosModelFromJson(String str) => List<ProductosModel>.from(json.decode(str).map((x) => ProductosModel.fromJson(x)));

String productosModelToJson(List<ProductosModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductosModel {
    ProductosModel({
        this.articulo,
        this.descripcion,
        this.ventaneto,
        this.porcila,
        this.porccarne,
        this.unidad,
        this.stock,
        this.pieces,
        this.numbered,
    });

    String articulo;
    String descripcion;
    int ventaneto;
    double porcila;
    double porccarne;
    Unidad unidad;
    double stock;
    double pieces;
    bool numbered;

    factory ProductosModel.fromJson(Map<String, dynamic> json) => ProductosModel(
        articulo: json["articulo"],
        descripcion: json["descripcion"],
        ventaneto: json["ventaneto"].toInt(),
        porcila: json["porcila"].toDouble(),
        porccarne: json["porccarne"].toDouble(),
        unidad: unidadValues.map[json["unidad"].toUpperCase()],
        stock: json["stock"].toDouble(),
        pieces: json["pieces"].toDouble(),
        numbered: json["numbered"],
    );

    Map<String, dynamic> toJson() => {
        "articulo": articulo,
        "descripcion": descripcion,
        "ventaneto": ventaneto,
        "porcila": porcila,
        "porccarne": porccarne,
        "unidad": unidadValues.reverse[unidad],
        "stock": stock,
        "pieces": pieces,
        "numbered": numbered,
    };
}

enum Unidad { UNI, CAJ, EMPTY, DIS, UNIDAD_UNI, UN, KIL, BOL, UNIDAD_CAJ, PAC, UNIDAD_KIL, LT, BID, KI, CAL }

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