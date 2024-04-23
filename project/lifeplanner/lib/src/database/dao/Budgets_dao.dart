import 'package:lifeplanner/src/modules/Finance/budget.dart';
import 'package:lifeplanner/src/modules/Organization/habittracker.dart';
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

  Future<Budget> getBudgetByMonth(int monthi) async {
    String month = Month.values[monthi - 1].name;
    print(month);
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
    );
    print(maps);
    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    } else {
      // Create a new budget for this month if not found
      Budget newBudget = Budget(
        month: Month.values.firstWhere((m) => m.name == month, orElse: () => Month.January),
        totalExpenseExpected: 0.0,
        totalIncomeExpected: 0.0,
        budgetExpenses: {},
        budgetIncomes: {},
      );

      // Insert into database
      int id = await db.insert('budgets', newBudget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      
      newBudget.id = id;

      // Return the newly created budget
      return newBudget;
    }
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

  Future<Map<int, String>> getCategoryNamesByIds(List<int> categoryIds) async {
    final db = await dbProvider;
    String inClause = categoryIds.join(',');
    final List<Map<String, dynamic>> results = await db.query(
      'budget_categories',
      where: 'id IN ($inClause)'
    );

    Map<int, String> categoryNames = {};
    for (var result in results) {
      categoryNames[result['id'] as int] = result['category'] as String;
    }
    return categoryNames;
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
