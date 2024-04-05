import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/modules/Job/vacation.dart';

class VacationsDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addVacation(Vacation vacation) async {
    final db = await dbProvider;
    return await db.insert('vacations', vacation.toMap());
  }

  Future<int> updateVacation(Vacation vacation) async {
    final db = await dbProvider;
    return await db.update(
      'vacations',
      vacation.toMap(),
      where: 'id = ?',
      whereArgs: [vacation.id],
    );
  }

  Future<int> deleteVacation(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'vacations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Vacation>> getAllVacations() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> vacationMaps = await db.query('vacations');
    return List.generate(vacationMaps.length, (i) {
      return Vacation.fromMap(vacationMaps[i]);
    });
  }

  Future<Vacation?> getVacationById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'vacations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Vacation.fromMap(maps.first);
    } else {
      return null; // Vacation not found
    }
  }
}
