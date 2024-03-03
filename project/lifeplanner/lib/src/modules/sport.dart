import 'package:lifeplanner/src/modules/activity.dart';
import 'package:schedules/schedules.dart';

abstract class Sport extends Activity
{
  Weekly schedule;

  Sport(name, description, this.schedule): super(name, description);
}