import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/modules/Job/job.dart';

class JobsDao {
  final dbProvider = DatabaseHelper.getDb();

  Future<int> addJob(Job job) async {
    final db = await dbProvider;
    return await db.insert('jobs', job.toMap());
  }

  Future<int> updateJob(Job job) async {
    final db = await dbProvider;
    return await db.update(
      'jobs',
      job.toMap(),
      where: 'id = ?',
      whereArgs: [job.id],
    );
  }

  Future<int> deleteJob(int id) async {
    final db = await dbProvider;
    return await db.delete(
      'jobs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Job>> getallJobs() async {
    final db = await dbProvider;
    
    final List<Map<String, dynamic>> jobMaps = await db.query('jobs');
    var jobFutur = jobMaps.map((jobMap) => Job.fromMap(jobMap)).toList();

    return await Future.wait(jobFutur);
  }


  Future<Job?> getJobsbyId(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(
      'jobs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Job.fromMap(maps.first);
    } else {
      return null; 
    }
  }
}
