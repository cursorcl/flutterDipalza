import 'package:flutter_test/flutter_test.dart';
import 'package:dipalza_movil/src/model/clientes_model.dart';

void main() {
  group('ClientesModel', () {
    test('fromJson creates correct model', () {
      final json = {
        'rut': '12345678-5',
        'codigo': '001',
        'razon': 'Empresa Test',
        'direccion': 'Calle 123',
        'telefono': '+56912345678',
        'ciudad': 'Santiago',
        'giro': 'Comercial',
        'codigoRuta': 'R01'
      };

      final cliente = ClientesModel.fromJson(json);

      expect(cliente.rut, '12345678-5');
      expect(cliente.codigo, '001');
      expect(cliente.razon, 'Empresa Test');
      expect(cliente.direccion, 'Calle 123');
      expect(cliente.telefono, '+56912345678');
      expect(cliente.ciudad, 'Santiago');
      expect(cliente.giro, 'Comercial');
      expect(cliente.ruta, 'R01');
    });

    test('fromJson handles null values', () {
      final json = <String, dynamic>{};

      final cliente = ClientesModel.fromJson(json);

      expect(cliente.rut, '');
      expect(cliente.codigo, '');
      expect(cliente.razon, '');
    });

    test('toJson creates correct JSON', () {
      final cliente = ClientesModel(
          rut: '12345678-5',
          codigo: '001',
          razon: 'Empresa Test',
          direccion: 'Calle 123',
          telefono: '+56912345678',
          ciudad: 'Santiago',
          giro: 'Comercial',
          ruta: 'R01');

      final json = cliente.toJson();

      expect(json['rut'], '12345678-5');
      expect(json['codigo'], '001');
      expect(json['razon'], 'Empresa Test');
    });

    test('clienteModelFromJson parses string', () {
      const jsonString =
          '{"rut": "12345678-5", "codigo": "001", "razon": "Test", "direccion": "Calle 1", "telefono": "123", "ciudad": "Santiago", "giro": "Com", "codigoRuta": "R1"}';

      final cliente = clienteModelFromJson(jsonString);

      expect(cliente.rut, '12345678-5');
    });

    test('clientesModelFromJson parses list', () {
      const jsonString =
          '[{"rut": "1", "codigo": "1", "razon": "A", "direccion": "a", "telefono": "1", "ciudad": "S", "giro": "C", "codigoRuta": "R"}, {"rut": "2", "codigo": "2", "razon": "B", "direccion": "b", "telefono": "2", "ciudad": "S", "giro": "C", "codigoRuta": "R"}]';

      final clientes = clientesModelFromJson(jsonString);

      expect(clientes.length, 2);
      expect(clientes[0].razon, 'A');
      expect(clientes[1].razon, 'B');
    });

    test('toJson -> fromJson round trip conserva los datos', () {
      final original = ClientesModel(
          rut: '12345678-5',
          codigo: '001',
          razon: 'Empresa Test',
          direccion: 'Calle 123',
          telefono: '+56912345678',
          ciudad: 'Santiago',
          giro: 'Comercial',
          ruta: 'R01');

      final reconstruido = ClientesModel.fromJson(original.toJson());

      expect(reconstruido.rut, original.rut);
      expect(reconstruido.codigo, original.codigo);
      expect(reconstruido.razon, original.razon);
      expect(reconstruido.direccion, original.direccion);
      expect(reconstruido.telefono, original.telefono);
      expect(reconstruido.ciudad, original.ciudad);
      expect(reconstruido.giro, original.giro);
      expect(reconstruido.ruta, original.ruta);
    });

    test('clientesModelToJson -> clientesModelFromJson round trip conserva los datos', () {
      final originales = [
        ClientesModel(
            rut: '1',
            codigo: '01',
            razon: 'A',
            direccion: 'a',
            telefono: '1',
            ciudad: 'S',
            giro: 'C',
            ruta: 'R1'),
        ClientesModel(
            rut: '2',
            codigo: '02',
            razon: 'B',
            direccion: 'b',
            telefono: '2',
            ciudad: 'S',
            giro: 'C',
            ruta: 'R2'),
      ];

      final jsonString = clientesModelToJson(originales);
      final reconstruidos = clientesModelFromJson(jsonString);

      expect(reconstruidos.length, 2);
      expect(reconstruidos[0].razon, 'A');
      expect(reconstruidos[0].ruta, 'R1');
      expect(reconstruidos[1].razon, 'B');
      expect(reconstruidos[1].ruta, 'R2');
    });
  });
}
