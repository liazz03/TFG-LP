import 'package:schedules/schedules.dart';
import 'dart:convert'; 

class Schedule_def {
  List<Weekly> schedule; 

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


  String asString() {
    // from numbers to names
    const List<String> weekdaysNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    return schedule.map((weekly) {
      String weekdaysStr = weekly.weekdays.map((day) => weekdaysNames[day - 1]).join(", ");
      String startTime = weekly.startDate.toIso8601String().substring(11, 16);
      String endTime = weekly.endDate != null ? weekly.endDate!.toIso8601String().substring(11, 16) : "No end time";
      return '$weekdaysStr $startTime - $endTime';
    }).join('\n');
  }


}
