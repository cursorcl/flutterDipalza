import 'log_model.dart';
import 'db_log_provider.dart';
import 'package:flutter/material.dart';

class ConsoleLogPage extends StatefulWidget {
  @override
  _ConsoleLogPageState createState() => _ConsoleLogPageState();
}

class _ConsoleLogPageState extends State<ConsoleLogPage> {
  LogModel ultimoLog;
  final List<Container> _logs = <Container>[];
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadLogsHistorico();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('Console LOG'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              color: Colors.red[300],
              onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
            ),
          ],
        ),
        body: Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, int index) => _logs[index],
            itemCount: _logs.length,
            reverse: true,
            padding: new EdgeInsets.all(.0),
          ),
        ),
      ),
    );
  }

  void _loadLogs() async {
    final List<LogModel> listaLogs = await DBLogProvider.db.getLogs(20);

    if (listaLogs != null && listaLogs.isNotEmpty) {
      ultimoLog = listaLogs[listaLogs.length - 1];
    }

    for (var item in listaLogs.reversed) {
      _creaTextoLog(item);
    }
  }

  Future<Null> _loadLogsHistorico() async {
    final List<LogModel> listaLogs =
        await DBLogProvider.db.getLogPaginados(ultimoLog, 10);

    if (listaLogs != null && listaLogs.isNotEmpty) {
      ultimoLog = listaLogs[listaLogs.length - 1];
    }

    for (var item in listaLogs) {
      _creaTextoLogHistorico(item);
    }
  }

  void _creaTextoLog(LogModel item) {
    setState(() {
      var texto = Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          item.log,
          maxLines: 1000,
          style: TextStyle(color: Colors.white, fontSize: 11.0),
        ),
      );
      _logs.insert(0, texto);
    });
  }

  void _creaTextoLogHistorico(LogModel item) {
    setState(() {
      var texto = Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          item.log,
          maxLines: 1000,
          style: TextStyle(color: Colors.white, fontSize: 11.0),
        ),
      );
      _logs.insert(_logs.length, texto);
    });
  }
}
