import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/modules/Finance/income.dart';
import 'package:sqflite/sqflite.dart';

class IncomesDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addIncome(Income income) async {
    final db = await dbProvider;
    return await db.insert('incomes', income.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteIncome(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'incomes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Income>> getAllIncomes() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> incomeMaps = await db.query('incomes');
    return List.generate(incomeMaps.length, (i) {
      return Income.fromMap(incomeMaps[i]);
    });
  }

  Future<Income?> getIncomeById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'incomes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Income.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateIncome(Income income) async {
    final db = await dbProvider;
    return await db.update(
      'incomes',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<List<Income>> getIncomesByYear(int year) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'incomes',
      where: "strftime('%Y', date) = ?",
      whereArgs: [year.toString()]
    );
    return List.generate(maps.length, (i) {
      return Income.fromMap(maps[i]);
    });
  }

  Future<double> getTotalIncomesByCategory(int categoryId) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM incomes WHERE category_id = ?',
      [categoryId]
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as double;
    } else {
      return 0.0;
    }
  }
}
