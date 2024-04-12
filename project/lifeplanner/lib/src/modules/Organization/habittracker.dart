import 'dart:convert';

enum Month {
  January, February, March, April, May, June,
  July, August, September, October, November, December,
}

class Habit {
  String name;
  List<int> completedDates; // List of days completed

  Habit({
    required this.name,
    required this.completedDates,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'completed_dates': jsonEncode(completedDates), // Encode the list of integers
    };
  }

  static Habit fromMap(Map<String, dynamic> map) {
    return Habit(
      name: map['name'],
      completedDates: List<int>.from(jsonDecode(map['completed_dates'])), // Decode to a list of integers
    );
  }
}

class HabitTracker {
  int? id;
  Month month;
  List<Habit> habits;
  int year;

  HabitTracker({
    this.id,
    required this.habits,
    required this.month,
    required this.year,
  });

  void deleteHabit(Habit habitt) {
    habits.removeWhere((habit) => habit.name == habitt.name);
  }

  Habit? getHabit(String habitName) {
    try {
      return habits.firstWhere((habit) => habit.name == habitName);
    } catch (e) {
      return null; 
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'month': month.toString().split('.').last,
    'year': year,
    'habits': jsonEncode(habits.map((habit) => habit.toMap()).toList()),
  };

  static HabitTracker fromMap(Map<String, dynamic> map) => HabitTracker(
    id: map['id'],
    month: Month.values.firstWhere((m) => m.toString() == 'Month.' + map['month']),
    year: map['year'],
    habits: (jsonDecode(map['habits']) as List).map((habitMap) => Habit.fromMap(habitMap)).toList(),
  );
  
}
