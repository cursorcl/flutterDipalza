import 'package:dipalza_movil/src/share/prefs_usuario.dart';
import 'package:dipalza_movil/src/utils/utils.dart';
import 'package:dipalza_movil/src/widget/fondo.widget.dart';
import 'package:flutter/material.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({Key key}) : super(key: key);

  @override
  _ConfiguracionPageState createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final _prefs = new PreferenciasUsuario();
  final _urlServicio = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRojoBase(),
        title: Container(
          child: Center(
            child: Text(
              'Configuración',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          FondoWidget(),
          _crearListaConfig(context),
        ],
      ),
    );
  }

  Widget _crearListaConfig(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              child: Icon(Icons.link),
              backgroundColor: colorRojoBase(),
              foregroundColor: Colors.white,
            ),
            title: Stack(
              children: <Widget>[
                Text('Dirección Servidor',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  // padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.centerRight,
                  child: _prefs.urlServicio != ''
                      ? Text('Conectado',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold))
                      : Text('Desconectado',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                Text(_prefs.urlServicio)
              ],
            ),
            trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios), onPressed: _showMyDialog),
          ),
        )
      ],
    );
  }

  Future<void> _showMyDialog() async {
    _urlServicio.text = _prefs.urlServicio;
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingresar Dirección Servidor'),
          elevation: 24.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _urlServicio,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.link,
                      color: Theme.of(context).primaryColor,
                    ),
                    labelText: 'Dirección Servidor',
                    helperText: '192.168.100.100:8080',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancelar'),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Guardar'),
              onPressed: () {
                _prefs.urlServicio = _urlServicio.text;
                setState(() {});
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
