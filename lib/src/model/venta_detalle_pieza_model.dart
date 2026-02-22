import 'dart:convert';

List<VentaDetallePiezaModel> listVentaDetallePiezaModel(String str) =>
    List<VentaDetallePiezaModel>.from(
        json.decode(str).map((x) => VentaDetallePiezaModel.fromJson(x)));

VentaDetallePiezaModel ventaDetallePiezaModelFromJson(String str) =>
    VentaDetallePiezaModel.fromJson(json.decode(str));

String ventaDetalleItemModelToJson(VentaDetallePiezaModel data) =>
    json.encode(data.toJson());

class VentaDetallePiezaModel {
  VentaDetallePiezaModel({
    this.id = -1,
    required this.detalleVentaId,
    required this.peso,
    required this.inventarioId,
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  int id;
  int detalleVentaId;
  double peso;
  int inventarioId;
  DateTime creadoEn;

  factory VentaDetallePiezaModel.fromJson(Map<String, dynamic> json) =>
      VentaDetallePiezaModel(
          id: json['id'],
          peso: json["peso"],
          detalleVentaId: json["detalleVentaId"],
          inventarioId: json["inventarioId"],
          creadoEn: DateTime.parse(json["creadoEn"]));

  Map<String, dynamic> toJson() => {
        "id": id,
        "peso": peso,
        "detalleVentaId": detalleVentaId,
        "inventarioId": inventarioId,
        "creadoEn": creadoEn.toIso8601String(),
      };
}
