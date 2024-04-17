import 'dart:convert';

import 'package:lifeplanner/src/modules/Activity/activity.dart';
import 'package:lifeplanner/src/modules/Activity/grades.dart';
import 'package:lifeplanner/src/modules/Organization/Schedule_def.dart';

enum Evaluation_type { EXAM, ASSIGNMENT }

class Subject extends Activity {
  int? id;
  Schedule_def? schedule;
  int dedication_time_x_week;
  int actual_dedication_time_x_week;
  int total_dedication_time;
  double? target_average;
  int? room;
  Grades grades;
  List<Evaluation> evaluations;

  Subject({this.id, name, description, this.schedule, required this.dedication_time_x_week, required this.actual_dedication_time_x_week, required this.total_dedication_time, this.target_average, 
  this.room, required this.grades, required this.evaluations}) : super(name, description);

  Map<String, dynamic> toMap() {

    final map = {
      'name': name,
      'description': description,
      'schedule': json.encode(schedule!.toMap()),
      'dedication_time_x_week': dedication_time_x_week,
      'actual_dedication_time_x_week': actual_dedication_time_x_week,
      'total_dedication_time': total_dedication_time,
      'target_average': target_average,
      'room': room,
      'grades': json.encode(grades.toMap()),
      'evaluations': json.encode(evaluations.map((e) => e.toMap()).toList()),
    };

    if (this.id != null) {  
      map['id'] = this.id;  
    }

    return map;

  }

  static Subject fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      schedule: Schedule_def.fromMap(json.decode(map['schedule'])),
      dedication_time_x_week: map['dedication_time_x_week'],
      actual_dedication_time_x_week: map['actual_dedication_time_x_week'],
      total_dedication_time: map['total_dedication_time'],
      target_average: map['target_average'],
      room: map['room'],
      grades: Grades.fromMap(json.decode(map['grades'])),
      evaluations: (json.decode(map['evaluations']) as List).map((e) => Evaluation.fromMap(e)).toList(),
    );
  }
}

class Evaluation {
  String name;
  DateTime date;
  Evaluation_type evaluation_type;

  Evaluation({
    required this.name,
    required this.date,
    required this.evaluation_type,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'evaluation_type': evaluation_type.toString().split('.').last,
    };
  }

  static Evaluation fromMap(Map<String, dynamic> map) {
    return Evaluation(
      name: map['name'],
      date: DateTime.parse(map['date']),
      evaluation_type: Evaluation_type.values.firstWhere((e) => e.toString() == 'Evaluation_type.${map['evaluation_type']}'),
    );
  }
}