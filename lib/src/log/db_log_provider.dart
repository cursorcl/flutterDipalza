import 'dart:io';


import 'log_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
export 'log_util.dart';

class DBLogProvider {
  static Database _dataBase;
  static final DBLogProvider db = DBLogProvider._();

  DBLogProvider._();

  Future<Database> get database async {
    if (_dataBase != null) return _dataBase;

    _dataBase = await initDB();
    return _dataBase;
  }

  initDB() async {
    Directory documentsDitectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDitectory.path, 'EmmaLogDB.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE logger ('
          ' id INTEGER PRIMARY KEY,'
          ' tipo TEXT,'
          ' log TEXT'
          ')');
    });
  }

  // Crear registros
  Future<int> nuevoLog(LogModel nuevo) async {
    final db = await database;
    return await db.insert('logger', nuevo.toJson());
  }

  Future<List<LogModel>> getTodos() async {
    final db = await database;
    final resp = await db.query('logger', orderBy: 'id desc');

    List<LogModel> list =
        resp.isNotEmpty ? resp.map((c) => LogModel.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<LogModel>> getLogs(int cantidad) async {
    final db = await database;
    final resp = await db.query(
      'logger',
      limit: cantidad,
      orderBy: 'id desc',
    );

    List<LogModel> list =
        resp.isNotEmpty ? resp.map((c) => LogModel.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<LogModel>> getLogPaginados(LogModel ultimo, int cantidad) async {
    final db = await database;
    final resp = await db.rawQuery(
        "SELECT * FROM logger where id != '${ultimo.id}' and  id <= '${ultimo.id}' order by id desc");

    List<LogModel> list = new List();

    if (resp.isNotEmpty) {
      resp.forEach((c) {
        if (cantidad > 0) {
          list.add(LogModel.fromJson(c));
          cantidad--;
        }
      });
    }
    return list;
  }

  Future<int> deleteAll() async {
    final db = await database;
    final resp = await db.rawDelete('DELETE FROM logger');
    return resp;
  }
}
