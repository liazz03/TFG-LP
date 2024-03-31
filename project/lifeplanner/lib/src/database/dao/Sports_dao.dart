import 'package:lifeplanner/src/modules/Activity/sport.dart';
import '../local_db_helper.dart';

class SportsDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addSport(Sport sport) async {
    final db = await dbProvider;
    return await db.insert('sports', sport.toMap());
  }

  Future<int> updateSport(Sport sport) async {
    final db = await dbProvider;
    return await db.update(
      'sports',
      sport.toMap(),
      where: 'id = ?',
      whereArgs: [sport.id],
    );
  }

  Future<int> deleteSport(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'sports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Sport>> getAllSports() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query('sports');

    return List.generate(maps.length, (i) {
      return Sport.fromMap(maps[i]);
    });
  }

    Future<void> resetCurrentDedicationAndUpdateTotal() async {
    final db = await dbProvider;
    // Assuming 'sports' table has 'actual_dedication_time_x_week' and 'total_dedicated_time' columns
    await db.transaction((txn) async {
      // First, update 'total_dedicated_time' for all records
      await txn.rawUpdate('''
        UPDATE sports SET 
          total_dedicated_time = total_dedicated_time + actual_dedication_time_x_week
      ''');

      // Then, reset 'actual_dedication_time_x_week' to 0
      await txn.rawUpdate('''
        UPDATE sports SET 
          actual_dedication_time_x_week = 0
      ''');
    });
  }

  Future<void> UpdateTotal() async {
    final db = await dbProvider;
    // Assuming 'sports' table has 'actual_dedication_time_x_week' and 'total_dedicated_time' columns
    await db.transaction((txn) async {
      // First, update 'total_dedicated_time' for all records
      await txn.rawUpdate('''
        UPDATE sports SET 
          total_dedicated_time = total_dedicated_time + actual_dedication_time_x_week
      ''');
    });
  }

}
