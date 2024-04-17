import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/modules/Activity/subject.dart';

class SubjectDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addSubject(Subject subject) async {
    final db = await dbProvider;
    return await db.insert('subjects', subject.toMap());
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await dbProvider;
    return await db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query('subjects');

    List<Subject> subjects = maps.map((map) => Subject.fromMap(map)).toList();

    for (var subject in subjects) {
      // only include future evaluations
      subject.evaluations = subject.evaluations
          .where((evaluation) => evaluation.date.isAfter(DateTime.now()))
          .toList();

      int index = subjects.indexOf(subject);
      subjects[index] = subject;
    }

    return subjects;
  }

  Future<Subject?> getSubjectById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    }
    return null;
  }
}
