import 'package:schedules/schedules.dart';

enum TASKS_STATE{PENDING, CANCELLED,COMPLETED,LATE,}


class Tasks {
  TASKS_STATE state;
  DateTime? deadline;
  String description;
  Schedule? timeslot;
  int? id;

  Tasks({
    required this.state,
    this.deadline,
    required this.description,
    this.timeslot,
    this.id,
  });

  Map<String, dynamic> toMap() {

    final Map<String,dynamic> map = {};
   
    map['state'] =  state.toString().split('.').last; // Convert enum to string
    map['description'] = description;

    // new instance, let SQLflite assign the id
    if (id != null){
      map['id'] = id;
    }

    // there is a deadline
    if (deadline != null){
      map['deadline'] = deadline?.toIso8601String();
    }
    
    // there is a date and time of doing it
    if (timeslot?.startDate != null && timeslot?.endDate != null){
      map['timeslot_start_date'] = timeslot?.startDate.toIso8601String();
      map['timeslot_end_date'] = timeslot?.endDate?.toIso8601String();
    }

    return map;

  }

  static Tasks fromMap(Map<String, dynamic> map) {
    return Tasks(
      id: map['id'],
      state: TASKS_STATE.values.firstWhere(
        (e) => e.toString() == 'TASKS_STATE.${map['state']}',
      ),
      description: map['description'],
      //deadline
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      //timeslot
      timeslot: map['timeslot_start_date'] != null && map['timeslot_end_date'] != null
          ? Daily(
              startDate: DateTime.parse(map['timeslot_start_date']),
              endDate: DateTime.parse(map['timeslot_end_date']),
              frequency: 0 // just one occurance
            )
          : null,
    );
  }

}
