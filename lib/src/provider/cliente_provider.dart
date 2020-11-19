import 'package:dipalza_movil/src/model/clientes_model.dart';
import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ClientesProvider {
  static final ClientesProvider clientesProvider = ClientesProvider._();

  ClientesProvider._() {
    //
  }

  Future<List<ClientesModel>> obtenerListaClientes(
      String codVendedor, String codRuta) async {
    final prefs = new PreferenciasUsuario();
    Uri url = Uri.http(
        prefs.urlServicio, '/clients/seller/$codVendedor/router/$codRuta');
    final resp = await http.get(url, headers: <String, String>{
      HttpHeaders.authorizationHeader: prefs.token
    });
    print(resp.body);
    return clientesModelFromJson(resp.body);
  }
}
