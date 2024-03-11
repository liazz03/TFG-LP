import 'package:lifeplanner/src/modules/Activity/activity.dart';
import 'package:schedules/schedules.dart';

class Sport extends Activity
{
  Weekly schedule;
  int dedication_time_x_week =0;
  int actual_dedication_time_x_week = 0;

  Sport(name, description, this.schedule, this.actual_dedication_time_x_week, this.dedication_time_x_week): super(name, description);
}