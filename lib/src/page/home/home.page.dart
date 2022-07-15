import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/optionHome.widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Titulo App'),
      // ),
      body: Column(
        children: <Widget>[
          creaLogo(),
          creaOpciones(context),
        ],
      ),
      floatingActionButton: creaBtnNuevaVenta(),
    );
  }

  Padding creaBtnNuevaVenta() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: HexColor('#ff7043'),
        tooltip: 'Ingresar Venta',
        child: Icon(
          Icons.add,
          size: 35.0,
        ),
      ),
    );
  }

  Widget creaLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: Hero(
            tag: 'logo_diplaza',
            child: Image(
              image: AssetImage('assets/image/logo_dipalza_transparente.png'),
              width: 200.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget creaOpciones(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 50),
      child: Table(
        defaultColumnWidth: FixedColumnWidth(150.0),
        // border: TableBorder.all(),
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: [
          TableRow(children: [
            OptionHomeWidget(
                router: 'estadistica',
                icon: Icons.pie_chart,
                textIcon: 'Estadistica',
                colorText: colorIconHome(),
                colorIcon: colorIconHome(),
                colorBackgraund: HexColor('4D#629c44')),
            OptionHomeWidget(
                router: 'ventas',
                icon: Icons.add_shopping_cart,
                textIcon: 'Ventas',
                colorText: colorIconHome(),
                colorIcon: colorIconHome(),
                colorBackgraund: HexColor('#4De61610')),
          ]),
          TableRow(children: [
            OptionHomeWidget(
                router: 'clientes',
                icon: Icons.group,
                textIcon: 'Clientes',
                colorText: colorIconHome(),
                colorIcon: colorIconHome(),
                colorBackgraund: HexColor('#4Dfefb64')),
            OptionHomeWidget(
                router: 'productos',
                icon: Icons.receipt,
                textIcon: 'Productos',
                colorText: colorIconHome(),
                colorIcon: colorIconHome(),
                colorBackgraund: HexColor('#4Dffc957')),
          ]),
          TableRow(children: [
            OptionHomeWidget(
                router: 'config',
                icon: Icons.settings_applications,
                textIcon: 'Configurar',
                colorText: colorIconHome(),
                colorIcon: colorIconHome(),
                colorBackgraund: HexColor('#4Db3b3ba')),
            OptionHomeWidget(
                router: 'login',
                icon: Icons.person,
                textIcon: 'Login',
                colorText: colorIconHome(),
                colorIcon: colorIconHome(),
                colorBackgraund: HexColor('#4Db3b3ba')),
          ]),
        ],
      ),
    );
  }
}
