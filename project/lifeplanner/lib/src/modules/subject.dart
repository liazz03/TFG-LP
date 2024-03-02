import 'package:lifeplanner/src/modules/activity.dart';
import 'package:lifeplanner/src/modules/grades.dart';
import 'package:schedules/schedules.dart';

class Subject extends Activity
{
  Daily schedule;
  int dedication_study_time_x_week;
  double target_average;
  int room;
  Grades grades;
  
  Subject(name, description, this.schedule, this.dedication_study_time_x_week, this.target_average, 
  this.room, this.grades): super(name, description);
}
