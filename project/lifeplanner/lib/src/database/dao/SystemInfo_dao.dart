import 'package:sqflite/sqflite.dart';

import '../local_db_helper.dart';

class SystemInfoDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<DateTime?> getLastEnterDate() async {
    final db = await dbProvider;
    List<Map> maps = await db.query('system_info', columns: ['last_enter']);
    if (maps.isNotEmpty) {
      return DateTime.parse(maps.first['last_enter']);
    }
    return null;
  }

  Future<void> setLastEnterDate(DateTime date) async {
    final db = await dbProvider;
    await db.insert(
      'system_info',
      {'id': 0, 'last_enter': date.toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

}
