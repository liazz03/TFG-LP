import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/modules/Activity/language.dart';

class LanguageDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addLanguage(Language language) async {
    final db = await dbProvider;
    return await db.insert('languages', language.toMap());
  }

  Future<int> updateLanguage(Language language) async {
    final db = await dbProvider;
    return await db.update(
      'languages',
      language.toMap(),
      where: 'id = ?',
      whereArgs: [language.id],
    );
  }

  Future<int> deleteLanguage(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'languages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Language>> getAllLanguages() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query('languages');

    return List.generate(maps.length, (i) {
      return Language.fromMap(maps[i]);
    });
  }

  Future<Language?> getLanguageById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'languages',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Language.fromMap(maps.first);
    }
    return null;
  }
}
