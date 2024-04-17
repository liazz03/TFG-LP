import 'package:lifeplanner/src/modules/Activity/course.dart';

import '../local_db_helper.dart';

class CourseDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addCourse(Course course) async {
    final db = await dbProvider;
    return await db.insert('courses', course.toMap());
  }

  Future<int> updateCourse(Course course) async {
    final db = await dbProvider;
    return await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<int> deleteCourse(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Course>> getAllCourses() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query('courses');

    return List.generate(maps.length, (i) {
      return Course.fromMap(maps[i]);
    });
  }

  Future<Course?> getCourseById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Course.fromMap(maps.first);
    }
    return null;
  }
}
