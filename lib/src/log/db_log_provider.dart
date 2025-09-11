import 'dart:io';

import 'log_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
export 'log_util.dart';

class DBLogProvider {
  DBLogProvider._();
  static final DBLogProvider db = DBLogProvider._();

  static Database? _database; // <-- anulable, NO late

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final opened = await initDB();
    _database = opened;
    return opened;
  }

  Future<Database> initDB() async { // <-- tipado
    // Asegúrese en main() de llamar a: WidgetsFlutterBinding.ensureInitialized();
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'EmmaLogDB.db');

    return openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE logger (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT,
            log  TEXT
          )
        ''');
      },
    );
  }

  // Crear registro
  Future<int> nuevoLog(LogModel nuevo) async {
    final db = await database;
    return db.insert('logger', nuevo.toJson());
  }

  Future<List<LogModel>> getTodos() async {
    final db = await database;
    final resp = await db.query('logger', orderBy: 'id DESC');
    return resp.isNotEmpty ? resp.map((c) => LogModel.fromJson(c)).toList() : <LogModel>[];
  }

  Future<List<LogModel>> getLogs(int cantidad) async {
    final db = await database;
    final resp = await db.query('logger', limit: cantidad, orderBy: 'id DESC');
    return resp.isNotEmpty ? resp.map((c) => LogModel.fromJson(c)).toList() : <LogModel>[];
  }

  Future<List<LogModel>> getLogPaginados(LogModel ultimo, int cantidad) async {
    final db = await database;
    // Evite interpolación; use parámetros y LIMIT
    final resp = await db.rawQuery(
      'SELECT * FROM logger WHERE id <> ? AND id <= ? ORDER BY id DESC LIMIT ?',
      [ultimo.id, ultimo.id, cantidad],
    );
    return resp.isNotEmpty ? resp.map((c) => LogModel.fromJson(c)).toList() : <LogModel>[];
  }

  Future<int> deleteAll() async {
    final db = await database;
    return db.delete('logger'); // más claro que rawDelete
  }
}
