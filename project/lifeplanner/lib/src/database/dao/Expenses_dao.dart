import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/modules/Finance/expense.dart';
import 'package:sqflite/sqflite.dart';

class ExpensesDao {
  final Future<Database> dbProvider = DatabaseHelper.getDb();

  Future<int> addExpense(Expense expense) async {
    final db = await dbProvider;
    return await db.insert('expenses', expense.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteExpense(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> expenseMaps = await db.query('expenses');
    return List.generate(expenseMaps.length, (i) {
      return Expense.fromMap(expenseMaps[i]);
    });
  }
  
  Future<List<Expense>> getExpensesByYear(int year) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> expenseMaps = await db.query(
      'expenses',
      where: "strftime('%Y', date) = ?",
      whereArgs: [year.toString()],
    );
    return List.generate(expenseMaps.length, (i) {
      return Expense.fromMap(expenseMaps[i]);
    });
  }

  Future<Expense?> getExpenseById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await dbProvider;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }
}
