import 'package:lifeplanner/src/modules/Organization/habittracker.dart';
import '../local_db_helper.dart';

class HabitTrackerDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<HabitTracker?> getHabitTrackerByMonthAndYear(Month month, int year) async {
    final db = await dbProvider;
    List<Map> maps = await db.query(
      'habit_trackers', // Your table name
      where: 'month = ? AND year = ?',
      whereArgs: [month.toString().split('.').last, year],
    );

    if (maps.isNotEmpty) {
      return HabitTracker.fromMap(maps.first.cast<String, dynamic>());
    }
    return null;
  }

  Future<int> addHabitTracker(HabitTracker habitTracker) async {
    final db = await dbProvider;
    return await db.insert('habit_trackers', habitTracker.toMap());
  }

  Future<int> updateHabitTracker(HabitTracker habitTracker) async {
    final db = await dbProvider;
    return await db.update(
      'habit_trackers',
      habitTracker.toMap(),
      where: 'id = ?',
      whereArgs: [habitTracker.id],
    );
  }

  Future<int> deleteHabitTracker(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'habit_trackers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<HabitTracker>> getAllHabitTrackers() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query('habit_trackers');

    return List.generate(maps.length, (i) {
      return HabitTracker.fromMap(maps[i]);
    });
  }

  Future<HabitTracker?> getHabitTrackerById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_trackers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return HabitTracker.fromMap(maps.first);
    }
    return null;
  }

}
