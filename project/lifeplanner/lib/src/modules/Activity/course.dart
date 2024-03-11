import 'package:lifeplanner/src/modules/Activity/activity.dart';

class Course extends Activity
{
  bool finished;
  int dedication_study_time_x_week;
  int actual_study_time_x_week = 0;
  int target_duration;  
  Course(name, description, this.finished, this.dedication_study_time_x_week, this.target_duration, this.actual_study_time_x_week): super(name, description);

}


