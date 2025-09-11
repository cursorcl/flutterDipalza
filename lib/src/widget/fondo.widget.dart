import 'dart:math';

import 'package:flutter/material.dart';

class FondoWidget extends StatelessWidget {
  const FondoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return makeBakground();
  }

  Widget makeBakground() {
    final gradiente = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: FractionalOffset(0.0, 0.6),
              end: FractionalOffset(0.0, 1.0),
              colors: [
            Color.fromRGBO(228, 175, 9, 0.5450980392156862),
            Color.fromRGBO(228, 175, 9, 0.8)
          ])),
    );

    final overGradient = Transform.rotate(
      angle: -pi / 5.0,
      child: Container(
        height: 360.0,
        width: 360.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(90.0),
            gradient: LinearGradient(colors: [
              Color.fromRGBO(252, 216, 0, 0.5),
              Color.fromRGBO(255, 1, 1, 0.5)
            ])),
      ),
    );

    return Stack(
      children: <Widget>[
        gradiente,
        Positioned(
          child: overGradient,
          top: -100.0,
        ),
      ],
    );
  }
  
}