import 'package:schedules/schedules.dart';

enum VacationType { FREE_DAY, LEAVE, VACATION, HOLIDAY }

class Vacation {
  int? id; // Make `id` nullable
  DateTime start_date;
  DateTime end_date;
  int days;
  String title;
  VacationType type;

  Vacation({
    this.id, 
    required this.start_date,
    required this.end_date,
    required this.days,
    required this.title,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'start_date': start_date.toIso8601String(),
      'end_date': end_date.toIso8601String(),
      'days': days,
      'title': title,
      'type': type.toString().split('.').last, // Convert enum to string
    };

    // Include `id` in the map only if it is not null
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  static Vacation fromMap(Map<String, dynamic> map) {
    return Vacation(
      id: map['id'],
      start_date: DateTime.parse(map['start_date']),
      end_date: DateTime.parse(map['end_date']),
      days: map['days'],
      title: map['title'],
      type: VacationType.values.firstWhere(
        (e) => e.toString() == 'VacationType.${map['type']}',
      ),
    );
  }
}
