import 'package:lifeplanner/src/activity/activity.dart';
import 'package:schedules/schedules.dart';

abstract class Sport extends Activity
{
  Daily schedule;

  Sport(name, description, this.schedule): super(name, description);
}