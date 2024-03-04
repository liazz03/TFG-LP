import 'package:lifeplanner/src/modules/Activity/activity.dart';

class Course extends Activity
{
  bool finished;
  int dedication_study_time_x_week;
  int target_duration;  
  Course(name, description, this.finished, this.dedication_study_time_x_week, this.target_duration): super(name, description);

}


