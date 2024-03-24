import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "user_db";

  static Future<Database> _getDb() async{
    return openDatabase(join(await getDatabasesPath(),_dbName),
    onCreate: (db, version) async => await _createTables(db,version),
    version: _version
    );
  }

  static Future<Database> getDb() async{
    return await _getDb();
  }

  static Future<void> _createTables(Database db, int version) async {
    String schemaSql = await _readSchema();
    List<String> statements = schemaSql.split(';');

    for (String statement in statements) {
      if (statement.trim().isNotEmpty) {
        await db.execute(statement);
      }
    }
  }

  static Future<String> _readSchema() async {
    return await rootBundle.loadString('assets/database/schema.sql');
  }

  static Future<int> addItem() async{
    final db = await _getDb();
    return await db.insert("sports", {'name':'basketball'});
  }

  static Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await _getDb();
    return await db.query('sports');
  }
  
}
