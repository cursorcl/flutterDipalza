import 'dart:convert';

List<RegistroItemRespModel> listRegistroItemRespModelFromJson(String str) => List<RegistroItemRespModel>.from(json.decode(str).map((x) => RegistroItemRespModel.fromJson(x)));

RegistroItemRespModel registroItemRespModelFromJson(String str) => RegistroItemRespModel.fromJson(json.decode(str));

String registroItemRespModelToJson(RegistroItemRespModel data) => json.encode(data.toJson());

class RegistroItemRespModel {
    RegistroItemRespModel({
        this.indice,
        this.rut,
        this.codigo,
        this.vendedor,
        this.fila,
        this.articulo,
        this.cantidad,
        this.neto,
        this.descuento,
        this.ila,
        this.carne,
        this.iva,
        this.precio,
        this.numeros,
        this.correlativos,
        this.pesos,
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
    DateTime fecha;

    factory RegistroItemRespModel.fromJson(Map<String, dynamic> json) => RegistroItemRespModel(
        indice: json["indice"],
        rut: json["rut"],
        codigo: json["codigo"],
        vendedor: json["vendedor"],
        fila: json["fila"],
        articulo: json["articulo"],
        cantidad: json["cantidad"].toDouble(),
        neto: json["neto"].toDouble(),
        descuento: json["descuento"].toDouble(),
        ila: json["ila"].toDouble(),
        carne: json["carne"].toDouble(),
        iva: json["iva"].toDouble(),
        precio: json["precio"].toDouble(),
        numeros: json["numeros"],
        correlativos: json["correlativos"],
        pesos: json["pesos"],
        fecha: json["fecha"] == null ? null : DateTime.parse(json["fecha"]
        ),
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
        "fecha": fecha.toIso8601String(),
    };
}
