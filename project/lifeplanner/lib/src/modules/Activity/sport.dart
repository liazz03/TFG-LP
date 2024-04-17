import 'dart:convert';

import 'package:lifeplanner/src/modules/Activity/activity.dart';
import 'package:lifeplanner/src/modules/Organization/Schedule_def.dart';

class Sport extends Activity {
  int? id; 
  Schedule_def? schedule;
  int dedication_time_x_week;
  int actual_dedication_time_x_week;
  int total_dedicated_time;

  Sport({
    this.id, 
    required String name,
    String? description,
    this.schedule,
    required this.actual_dedication_time_x_week,
    required this.dedication_time_x_week,
    required this.total_dedicated_time,
  }) : super(name, description);

  Map<String, dynamic> toMap() {
    var map = {
      'name': name,
      'description': description,
      'dedication_time_x_week': dedication_time_x_week,
      'actual_dedication_time_x_week': actual_dedication_time_x_week,
      'total_dedicated_time': total_dedicated_time,
      'schedule': this.schedule != null ? jsonEncode(this.schedule?.toMap()['schedule']) : null,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  static Sport fromMap(Map<String, dynamic> map) {
    return Sport(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      schedule: map['schedule'] != null ? Schedule_def.fromMap({'schedule': jsonDecode(map['schedule'])}) : null,
      actual_dedication_time_x_week: map['actual_dedication_time_x_week'],
      dedication_time_x_week: map['dedication_time_x_week'],
      total_dedicated_time: map['total_dedicated_time'],
    );
  }

}