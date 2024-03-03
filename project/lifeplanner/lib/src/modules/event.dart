import 'package:lifeplanner/src/modules/activity.dart';
import 'package:schedules/schedules.dart';

enum EVENT_STATE {Scheduled, Finished, Cancelled,}

class Event extends Activity
{
  Schedule date_time;
  EVENT_STATE state;

  Event(name, description, this.date_time, this.state): super(name, description);
}