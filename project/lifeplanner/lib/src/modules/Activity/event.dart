import 'package:schedules/schedules.dart';

enum EVENT_STATE {Scheduled, Finished, Cancelled,}

class Event
{
  String name;
  String description;
  Schedule date_time;
  EVENT_STATE state;

  Event( this.name, this.description, this.date_time, this.state);
}
