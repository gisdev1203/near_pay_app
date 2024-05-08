import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static late Database _database;

  Future<Database> get database async {
    return _database;

  }

  Future<Database> initDatabase() async {
    final String path = join(await getDatabasesPath(), 'your_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS your_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        column1 TEXT,
        column2 INTEGER
      )
    ''');
  }

  Future<int> insertData(Map<String, dynamic> data, String tableName) async {
    final Database db = await database;
    return await db.insert(tableName, data);
  }

  Future<int> updateData(Map<String, dynamic> data, String tableName, int id) async {
    final Database db = await database;
    return await db.update(
      tableName,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteData(String tableName, int id) async {
    final Database db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getData(String tableName) async {
    final Database db = await database;
    return await db.query(tableName);
  }
}
