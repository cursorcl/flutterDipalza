import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
    LoginModel({
        this.rut,
        this.password,
    });

    String rut;
    String password;

    factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        rut: json["rut"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "rut": rut,
        "password": password,
    };
}