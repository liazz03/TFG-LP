import 'package:lifeplanner/src/modules/Finance/budget.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lifeplanner/src/database/local_db_helper.dart';

class BudgetDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addBudget(Budget budget) async {
    final db = await dbProvider;
    return await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllBudgetCategories() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> categories = await db.query('budget_categories');
    return categories;
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await dbProvider;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Budget>> getAllBudgets() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query('budgets');
    return List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });
  }

  Future<Budget?> getBudgetById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    } else {
      return null;
    }
  }
}
