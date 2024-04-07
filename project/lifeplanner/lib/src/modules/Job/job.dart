import 'dart:convert';

import 'package:lifeplanner/src/database/dao/Incomes_dao.dart';
import 'package:lifeplanner/src/database/dao/Vacations_dao.dart';
import 'package:lifeplanner/src/modules/Finance/income.dart';
import 'package:lifeplanner/src/modules/Job/vacation.dart';
import 'package:lifeplanner/src/modules/Organization/Schedule_def.dart';

enum JobType { REMOTE, ONSITE, HYBRID }

class Job {
  int? id;
  String name;
  Schedule_def? schedule;
  JobType type;
  int total_hours;
  Income income;
  List<Vacation>? vacations_fd_leaves;

  Job({this.id, this.schedule, required this.type, required this.total_hours, required this.income, this.vacations_fd_leaves = const [], required this.name });

  
  Map<String, dynamic> toMap() {
    var map = {
      'name': name,
      'type': type.toString().split('.').last, // enum to string,
      'total_hours': total_hours,
      'income_id': income.id,
      'schedule': this.schedule != null ? jsonEncode(this.schedule?.toMap()['schedule']) : null,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  static Future<Job> fromMap(Map<String, dynamic> map) async {
    
    // fetch income from db
    IncomesDao inc_dao = IncomesDao();
    final income_ = await inc_dao.getIncomeById(map['income_id']);
    if (income_ == null) {
      throw Exception('Income with ID ${map['income_id']} not found');
    }

    // fetch vacations from db (if any)
    VacationsDao vacationsDao = VacationsDao();
    List<Vacation> vacations = [];
    vacations = await vacationsDao.getVacationsByJobId(map['id']);
  

    Job job =  Job(
      id: map['id'],
      name: map['name'],
      schedule: map['schedule'] != null ? Schedule_def.fromMap({'schedule': jsonDecode(map['schedule'])}) : null,
      type: JobType.values.firstWhere(
        (e) => e.toString() == 'JobType.${map['type']}',
      ),
      total_hours: map['total_hours'],
      income: income_ ,
      vacations_fd_leaves: vacations,
    );
    
    return job;
  }
}