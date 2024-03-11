import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "user_db";

  static Future<Database> _getDb() async{
    return openDatabase(join(await getDatabasesPath(),_dbName),
    onCreate: (db, version) async => 
    await db.execute('CREATE TABLE IF NOT EXISTS tabla_prueba(id INTEGER PRIMARY KEY, name TEXT)'), 
    version: _version
    );
  }

  static Future<int> addItem() async{
    final db = await _getDb();
    return await db.insert("tabla_prueba", {'name':'Jhon'});
  }

  static Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await _getDb();
    return await db.query('tabla_prueba');
  }
  
}
