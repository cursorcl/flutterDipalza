import 'package:dipalza_movil/src/page/cliente/clientes.popup.page.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:flutter/material.dart';

class ClientesSelectWidget extends StatefulWidget {
  ClientesSelectWidget({Key key}) : super(key: key);

  @override
  _ClientesSelectWidgetState createState() => _ClientesSelectWidgetState();
}

class _ClientesSelectWidgetState extends State<ClientesSelectWidget> { 
  SimpleDialog dialogCliente = new SimpleDialog();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    this.dialogCliente = SimpleDialog(
      
      title: Center(child: Text('Cliente')),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      children: <Widget>[
        ClientesPopUpPage(),
        SizedBox(height: 5.0,)
      ],
    );

    return FloatingActionButton(
      onPressed: () {
        showDialog<void>(context: context, builder: (context) => this.dialogCliente);
      },
      backgroundColor: HexColor('#ff7043'),
      tooltip: 'Ingresar Venta',
      child: Icon(
        Icons.add,
        size: 35.0,
      ),
    );
  }



 
}

