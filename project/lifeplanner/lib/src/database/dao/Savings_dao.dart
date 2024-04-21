import 'package:sqflite/sqflite.dart';
import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/modules/Finance/saving.dart';

class SavingsDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addSaving(Saving saving) async {
    final db = await dbProvider;
    return await db.insert('savings', saving.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateSaving(Saving saving) async {
    final db = await dbProvider;
    return await db.update(
      'savings',
      saving.toMap(),
      where: 'id = ?',
      whereArgs: [saving.id],
    );
  }

  Future<int> deleteSaving(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Saving>> getAllSavings() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query('savings');
    return List.generate(maps.length, (i) {
      return Saving.fromMap(maps[i]);
    });
  }

  Future<Saving?> getSavingById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Saving.fromMap(maps.first);
    } else {
      return null;
    }
  }
}
