import 'package:lifeplanner/src/modules/activity.dart';

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

  HabitTracker({this.habits = const []});

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
