import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

import '../share/app.navigator.dart';

Future<void> showAlertDialog(
    BuildContext context, String mensaje, IconData? icono) {
  return showDialog(
    context: context,
    barrierDismissible: false, // Permite cerrar tocando fuera del diálogo
    builder: (context) {
      return AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Icon(
          icono ?? Icons.error_outline, // Manejo de nulos moderno
          color: colorRojoBase(), // Asumo que esta función existe en tu scope
          size: 60.0,
        ),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cerrar',
              style: TextStyle(color: colorRojoBase()),
            ),
            // Asegúrate que AppNavigator maneje el contexto global o pásalo si es necesario
            onPressed: () => AppNavigator.pop(),
          )
        ],
      );
    },
  );
}
