import 'dart:convert';

List<ClientesModel> clientesModelFromJson(String str) => List<ClientesModel>.from(json.decode(str).map((x) => ClientesModel.fromJson(x)));

String clientesModelToJson(List<ClientesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClientesModel {
    ClientesModel({
        this.rut,
        this.codigo,
        this.razon,
        this.direccion,
        this.telefono,
        this.ciudad,
    });

    String rut;
    String codigo;
    String razon;
    String direccion;
    String telefono;
    String ciudad;

    factory ClientesModel.fromJson(Map<String, dynamic> json) => ClientesModel(
        rut: json["rut"],
        codigo: json["codigo"],
        razon: json["razon"],
        direccion: json["direccion"],
        telefono: json["telefono"],
        ciudad: json["ciudad"],
    );

    Map<String, dynamic> toJson() => {
        "rut": rut,
        "codigo": codigo,
        "razon": razon,
        "direccion": direccion,
        "telefono": telefono,
        "ciudad": ciudad,
    };
}