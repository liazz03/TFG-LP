import 'package:lifeplanner/src/modules/Activity/course.dart';

enum LANGUAGE_LEVEL {A1, A2, B1, B2, C1,C2,}

class Language extends Course {
  LANGUAGE_LEVEL level;

  Language(this.level, super.name, super.description, super.id, super.finished, 
  super.dedication_study_time_x_week, super.actual_study_time_x_week, super.total_dedication_time);

  Map<String, dynamic> toMap() {
    var map = super.toMap(); 
    map['level'] = level.toString().split('.').last; 
    return map;
  }

  static Language fromMap(Map<String, dynamic> map) {
    return Language(
      LANGUAGE_LEVEL.values.firstWhere((e) => e.toString().split('.').last == map['level']), 
      map['name'],
      map['description'],
      map['id'],
      map['finished'] == 1, 
      map['dedication_study_time_x_week'],
      map['actual_study_time_x_week'],
      map['total_dedication_time'],
    );
  }

}

