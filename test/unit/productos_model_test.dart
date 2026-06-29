import 'package:flutter_test/flutter_test.dart';
import 'package:dipalza_movil/src/model/producto_model.dart';

void main() {
  group('ProductosModel', () {
    test('fromJson creates correct model', () {
      final json = {
        'articulo': 'P001',
        'descripcion': 'Producto Test',
        'ventaNeto': 1000.0,
        'porcIla': 10.5,
        'porcCarne': 89.5,
        'unidad': 'UNI',
        'stock': 50.0,
        'numbered': true,
        'numerados': <dynamic>[],
        'codigoila': 'I001',
        'pieces': 5.0,
        'stockVentas': 10.0,
        'piezasVentas': 2.0
      };

      final producto = ProductosModel.fromJson(json);

      expect(producto.articulo, 'P001');
      expect(producto.descripcion, 'Producto Test');
      expect(producto.ventaneto, 1000.0);
      expect(producto.porcila, 10.5);
      expect(producto.porccarne, 89.5);
      expect(producto.unidad, 'UNI');
      expect(producto.stock, 50.0);
      expect(producto.numbered, true);
    });

    test('toJson creates correct JSON', () {
      final producto = ProductosModel(
          articulo: 'P001',
          descripcion: 'Producto Test',
          ventaneto: 1000.0,
          precioLista2: 1000.0,
          porcila: 10.5,
          porccarne: 89.5,
          unidad: 'UNI',
          stock: 50.0,
          numbered: true,
          numerados: [],
          codigoila: 'I001',
          pieces: 5.0,
          stockVentas: 10.0,
          piezasVentas: 2.0);

      final json = producto.toJson();

      expect(json['articulo'], 'P001');
      expect(json['ventaNeto'], 1000.0);
      expect(json['numbered'], true);
    });

    test('productoModelFromJson parses single object', () {
      const jsonString =
          '{"articulo": "P1", "descripcion": "A", "ventaNeto": 100.0, "porcIla": 10.0, "porcCarne": 90.0, "unidad": "UNI", "stock": 10.0, "numbered": false, "numerados": [], "codigoila": "I1", "pieces": 1.0, "stockVentas": 1.0, "piezasVentas": 1.0}';

      final producto = productoModelFromJson(jsonString);

      expect(producto.articulo, 'P1');
    });
  });

  group('Unidad enum', () {
    test('unidadValues maps correctly', () {
      expect(unidadValues.map['UNI'], Unidad.UNI);
      expect(unidadValues.map['CAJ'], Unidad.CAJ);
      expect(unidadValues.map['KIL'], Unidad.KIL);
      expect(unidadValues.map[''], Unidad.EMPTY);
    });

    test('unidadValuesDetalle maps correctly', () {
      expect(unidadValuesDetalle.map['Unidad'], Unidad.UNI);
      expect(unidadValuesDetalle.map['Caja'], Unidad.CAJ);
      expect(unidadValuesDetalle.map['Kilo'], Unidad.KIL);
      expect(unidadValuesDetalle.map['Litro'], Unidad.LT);
    });
  });
}
