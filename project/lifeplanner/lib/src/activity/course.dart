import 'package:lifeplanner/src/activity/activity.dart';

class Course extends Activity
{
  bool finished;
  int dedication_time_x_week;
  int target_duration;
  
  Course(name, description, this.finished, this.dedication_time_x_week, this.target_duration): super(name, description);
}

