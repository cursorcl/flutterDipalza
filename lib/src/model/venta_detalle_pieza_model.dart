import 'dart:convert';

List<VentaDetallePiezaModel> listVentaDetallePiezaModel(String str) =>
    List<VentaDetallePiezaModel>.from(json.decode(str).map((x) => VentaDetallePiezaModel.fromJson(x)));

VentaDetallePiezaModel ventaDetallePiezaModelFromJson(String str) => VentaDetallePiezaModel.fromJson(json.decode(str));

String ventaDetalleItemModelToJson(VentaDetallePiezaModel data) => json.encode(data.toJson());

class VentaDetallePiezaModel {
  VentaDetallePiezaModel({this.id = -1, required this.peso, required this.invId, required this.creadoEn});

  int id;
  double peso;
  int invId;
  DateTime creadoEn;

  factory VentaDetallePiezaModel.fromJson(Map<String, dynamic> json) =>
      VentaDetallePiezaModel(id: json['id'], peso: json["peso"], invId: json["invId"], creadoEn: json["creadoEn"]);

  Map<String, dynamic> toJson() => {"id": id, "peso": peso, "invId": invId, "creadoEn": creadoEn};
}
