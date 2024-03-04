import 'package:lifeplanner/src/modules/Finance/income.dart';
import 'package:lifeplanner/src/modules/Job/vacation.dart';
import 'package:schedules/schedules.dart';

enum JobType { REMOTE, ONSITE, HYBRID }

class Job {
  Weekly schedule;
  JobType type;
  int hours;
  Income income;
  List<Vacation> vacations_fd_leaves;

  Job({required this.schedule, required this.type, required this.hours, required this.income, this.vacations_fd_leaves = const [] });

  @override
  String toString() {
    return 'Job{schedule: $schedule, type: $type, hours: $hours}';
  }
}