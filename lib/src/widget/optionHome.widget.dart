import 'package:flutter/material.dart';

class OptionHomeWidget extends StatelessWidget {

  final String router;
  final IconData icon;
  final String textIcon;
  final Color? colorText;
  final Color? colorIcon;
  final Color? colorBackgraund;

  const OptionHomeWidget({required this.router, required this.icon, required this.textIcon, this.colorText, this.colorIcon, this.colorBackgraund});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      width: 150,
      height: 150,
      
      decoration: new BoxDecoration(
        color: colorBackgraund != null ? colorBackgraund : Theme.of(context).primaryColorLight,
        shape: BoxShape.circle,
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          shape: CircleBorder(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Icon(
                this.icon,
                color: colorIcon != null ? colorIcon : Theme.of(context).primaryColor,
                size: 70.0,
              ),
            ),
            Center(
              child: Text(
                '$textIcon',
                style: TextStyle(color: colorText != null ? colorText : Colors.white),
              ),
            )
          ],
        ),
        onPressed: () => Navigator.pushNamed(context, '$router'),
      ),
    );
  }
}