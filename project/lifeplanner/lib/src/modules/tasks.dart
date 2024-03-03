import 'package:schedules/schedules.dart';

enum TASKS_STATE{PENDING, CANCELLED,COMPLETED,LATE,}


class Tasks {
  TASKS_STATE state;
  DateTime? deadline;
  String description;
  DateTime? date_of_doing;
  Schedule? timeslot;

  Tasks({
    required this.state,
    this.deadline,
    required this.description,
    this.date_of_doing,
    this.timeslot,
  });
}
