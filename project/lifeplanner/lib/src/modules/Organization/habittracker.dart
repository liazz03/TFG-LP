import 'package:lifeplanner/src/modules/Activity/activity.dart';
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


  Habit({
    required this.name,
    required this.description,
    this.completedDates = const [],
    this.related_activity,
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
