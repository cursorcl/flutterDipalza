import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

void showAlert(BuildContext context, String mensaje, IconData icono) {

  showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Icon(
          icono != null ? icono : Icons.error_outline,
          color: colorRojoBase(),
          size: 60.0,
        ),
        content: Text(mensaje),
        actions: <Widget>[
          FlatButton(
            child: Text('Cerrar', style: TextStyle(color: colorRojoBase()),),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
    },
  );
}

void showBlock(BuildContext context, String mensaje) {
  showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100.0,
            height: 100.0,
            child: Image.asset(
              'assets/gift/spinner_loading.gif',
              colorBlendMode: BlendMode.srcATop,
              color: Colors.white,
            ),
          ),
        ],
      );
    },
  );
}
