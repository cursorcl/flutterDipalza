import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
    LoginResponseModel({
        this.code,
        this.name,
        this.rut,
        this.token,
    });

    String code;
    String name;
    String rut;
    String token;

    factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
        code: json["code"],
        name: json["name"],
        rut: json["rut"],
        token: json["token"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "rut": rut,
        "token": token,
    };
}
