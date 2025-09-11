import 'dart:convert';

List<ClientesModel> clientesModelFromJson(String str) => List<ClientesModel>.from(json.decode(str).map((x) => ClientesModel.fromJson(x)));

String clientesModelToJson(List<ClientesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClientesModel {
    ClientesModel({
        required this.rut,
        required this.codigo,
        required this.razon,
        required this.direccion,
        required this.telefono,
        required this.ciudad,
    });

    String rut;
    String codigo;
    String razon;
    String direccion;
    String telefono;
    String ciudad;

    factory ClientesModel.fromJson(Map<String, dynamic> json) => ClientesModel(
        rut: json["Rut"],
        codigo: json["Codigo"],
        razon: json["Razon"],
        direccion: json["Direccion"],
        telefono: json["Telefono"],
        ciudad: json["Ciudad"],
    );

    Map<String, dynamic> toJson() => {
        "Rut": rut,
        "Codigo": codigo,
        "Razon": razon,
        "Direccion": direccion,
        "Telefono": telefono,
        "Ciudad": ciudad,
    };
}