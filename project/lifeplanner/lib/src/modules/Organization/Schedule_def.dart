import 'package:schedules/schedules.dart';
import 'dart:convert'; 

class Schedule_def {
  List<Weekly> schedule; // represents several days ana same timeslot for those days

  Schedule_def({required this.schedule});

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> scheduleMaps = schedule.map((weekly) {
      return {
        'start_date': weekly.startDate.toIso8601String(),
        'end_date': weekly.endDate?.toIso8601String(),
        'weekdays': jsonEncode(weekly.weekdays),
        'frequency': weekly.frequency,
      };
    }).toList();

    // Return the schedule as part of a Map, but not JSON-encoded here
    return {
      'schedule': scheduleMaps, // List<Map<String, dynamic>>
    };
  }



static Schedule_def fromMap(Map<String, dynamic> decodedMap) {
  List<dynamic> scheduleList = decodedMap['schedule'];
  List<Weekly> schedule = scheduleList.map((item) {
    return Weekly(
      startDate: DateTime.parse(item['start_date']),
      endDate: item['end_date'] != null ? DateTime.parse(item['end_date']) : null,
      weekdays: List<int>.from(jsonDecode(item['weekdays'])),
      frequency: item['frequency'],
    );
  }).toList();

  return Schedule_def(schedule: schedule);
}

}
