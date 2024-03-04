import 'package:schedules/schedules.dart';

enum VacationType { FREE_DAY, LEAVE, VACATION, HOLIDAY }

class Vacation {
  Schedule schedule;
  int days;
  String title;
  VacationType type;

  Vacation({required this.schedule, required this.days, required this.title, required this.type});

  @override
  String toString() {
    return 'Vacation{schedule: $schedule, days: $days, title: $title, type: $type}';
  }
}
