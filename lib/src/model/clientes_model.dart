import 'dart:convert';

ClientesModel clienteModelFromJson(String str) => ClientesModel.fromJson(json.decode(str));


List<ClientesModel> clientesModelFromJson(String str) => List<ClientesModel>.from(json.decode(str).map((x) => ClientesModel.fromJson(x)));

String clientesModelToJson(List<ClientesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClientesModel {
    String rut;
    String codigo;
    String razon;
    String direccion;
    String telefono;
    String ciudad;
    String giro;
    String ruta;

    ClientesModel({
        required this.rut,
        required this.codigo,
        required this.razon,
        required this.direccion,
        required this.telefono,
        required this.ciudad,
        required this.giro,
        required this.ruta
    });

    factory ClientesModel.fromJson(Map<String, dynamic> json) => ClientesModel(
        rut: json["rut"] ?? "",
        codigo: json["codigo"] ?? "",
        razon: json["razon"] ?? "",
        direccion: json["direccion"] ?? "",
        telefono: json["telefono"] ?? "",
        ciudad: json["ciudad"] ?? "",
        giro: json["giro"] ?? "",
        ruta: json["tuta"] ?? ""
    );

    Map<String, dynamic> toJson() => {
        "Rut": rut,
        "Codigo": codigo,
        "Razon": razon,
        "Direccion": direccion,
        "Telefono": telefono,
        "Ciudad": ciudad,
        "Giro": giro,
        "Ruta": ruta
    };
}