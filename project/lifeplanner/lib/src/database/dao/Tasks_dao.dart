import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:schedules/schedules.dart';

import '../../modules/Organization/tasks.dart';

class TasksDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addTask(Tasks task) async {
    final db = await dbProvider;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Tasks task) async {
    final db = await dbProvider;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Tasks>> getAllTasks() async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return Tasks.fromMap(maps[i]);
    });
  }

  Future<Tasks?> getTaskById(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Tasks.fromMap(maps.first);
    }
    return null;
  }

  Future<void> markOverdueTasksAsLate() async {
    final db = await dbProvider;
    final now = DateTime.now().toIso8601String();

    // Find all tasks that are overdue and not already completed or cancelled
    List<Tasks> tasks = await getAllTasks();
    List<Tasks> overdueTasks = tasks.where((task) =>
        task.state != TASKS_STATE.COMPLETED &&
        task.deadline != null &&
        task.deadline!.isBefore(DateTime.now())).toList();

    // Update each overdue task's state to 'LATE'
    for (Tasks task in overdueTasks) {
      task.state = TASKS_STATE.LATE;
      await updateTask(task);
    }
  }

}
