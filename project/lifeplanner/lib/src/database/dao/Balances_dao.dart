import 'package:sqflite/sqflite.dart';
import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/modules/Finance/balance.dart';

class BalanceDao {
  final Future<Database> dbProvider = DatabaseHelper.getDb();

  Future<int> setBalance(Balance balance) async {
    final db = await dbProvider;
    return await db.insert(
      'balance',
      balance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Balance?> getBalance() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'balance',
      where: 'id = 0',
    );

    if (maps.isNotEmpty) {
      return Balance.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteBalance() async {
    final db = await dbProvider;
    return await db.delete(
      'balance',
      where: 'id = 0',
    );
  }
}
