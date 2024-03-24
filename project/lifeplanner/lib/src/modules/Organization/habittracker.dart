import 'package:lifeplanner/src/modules/Activity/activity.dart';
import 'package:lifeplanner/src/modules/Organization/project.dart';
enum Month {
  January,
  February,
  March,
  April,
  May,
  June,
  July,
  August,
  September,
  October,
  November,
  December,
}

class Habit {
  String name;
  String description;
  List<DateTime> completedDates;
  Activity? related_activity;
  Project? related_project;


  Habit({
    required this.name,
    required this.description,
    this.completedDates = const [],
    this.related_activity,
    this.related_project
  });
}

class HabitTracker {
  List<Habit> habits;
  Month month;
  HabitTracker({this.habits = const [], required this.month});

  void addHabit(Habit habit) {
    habits.add(habit);
  }

  void removeHabit(Habit habit) {
    habits.remove(habit);
  }

  void completeHabit(Habit habit, DateTime date) {
    habit.completedDates.add(date);
  }
}
