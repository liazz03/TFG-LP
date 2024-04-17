import 'package:lifeplanner/src/modules/Activity/activity.dart';

class Course extends Activity
{
  int? id;
  bool finished;
  int dedication_study_time_x_week; // target
  int actual_study_time_x_week = 0; // reset every week
  int total_dedication_time;  
  Course(name, description, this.id, this.finished, this.dedication_study_time_x_week, this.actual_study_time_x_week, this.total_dedication_time): super(name, description);


  // object -> sql
  Map<String, dynamic> toMap() {
    final map = {
      'name': this.name,
      'description': this.description,
      'finished': this.finished ? 1 : 0,
      'dedication_study_time_x_week': this.dedication_study_time_x_week,
      'actual_study_time_x_week': this.actual_study_time_x_week,
      'total_dedication_time': this.total_dedication_time,
    };

    if (this.id != null) {  
      map['id'] = this.id;  
    }

    return map;
  }

  // sql -> object
  static Course fromMap(Map<String, dynamic> map) {
    return Course(
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


