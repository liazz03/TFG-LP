import 'package:schedules/schedules.dart';

class Sprint {
  Schedule SprintexpectedDuration;
  Schedule ProjectexpectedDuration;
  int totalHoursDedicated;
  double percentageOfTotalProjectTime;
  String name;
  String description;
  bool done;

  Sprint({
    required this.SprintexpectedDuration,
    this.totalHoursDedicated = 0,
    required this.name,
    required this.description,
    this.done = false,
    required this.ProjectexpectedDuration,
    this.percentageOfTotalProjectTime = 0.0
  }){
    // check sprint expected duration is within the projects duration
    if (!isSprintWithinProject()) {
      throw ArgumentError('SprintexpectedDuration must be within ProjectexpectedDuration');
    }
    
    percentageOfTotalProjectTime = calculatePercentageOfTotalProjectTime();
  }

  bool isSprintWithinProject() {
    return SprintexpectedDuration.startDate.isAfter(ProjectexpectedDuration.startDate) &&
        SprintexpectedDuration.endDate!.isBefore(ProjectexpectedDuration.endDate!);
  }

  double calculatePercentageOfTotalProjectTime() {
    // Calculate the percentage of total project time
    // For example, if the total project time is 100 hours and this sprint is 20 hours,
    // the percentage would be 20%.
    
    Duration? interval_project = ProjectexpectedDuration.endDate?.difference(ProjectexpectedDuration.startDate);
    Duration? interval_spint = SprintexpectedDuration.endDate?.difference(SprintexpectedDuration.startDate);

    if (interval_project == null || interval_spint == null) return 0.0;

    double percentage = (interval_spint.inDays / interval_project.inDays) * 100;

    return percentage;
  }

  @override
  String toString() {
    return 'Sprint{timeframe: $SprintexpectedDuration, totalHoursDedicated: $totalHoursDedicated, percentageOfTotalProjectTime: $percentageOfTotalProjectTime, name: $name, description: $description, done: $done}';
  }
}
