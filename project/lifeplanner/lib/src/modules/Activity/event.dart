import 'dart:convert';
import 'package:schedules/schedules.dart';

enum EVENT_STATE { Scheduled, Finished, Cancelled }

class Event {
  int? id;
  String name;
  String description;
  Daily timeslot;
  EVENT_STATE state;
  int? categoryId;

  Event({
    this.id,
    required this.name,
    required this.description,
    required this.timeslot,
    required this.state,
    this.categoryId,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name,
      'description': description,
      'timeslot_start_date': timeslot.startDate.toIso8601String(),
      'state': state.toString().split('.').last,
      'category_id': categoryId,
    };

    if(id != null){
      map['id'] = id;
    }

    // An event can have only a start time.
    if (timeslot.endDate != null) {
      map['timeslot_end_date'] = timeslot.endDate!.toIso8601String();
    }

    return map;
  }


  static Event fromMap(Map<String, dynamic> map) {
    DateTime? endDate;
    if (map['timeslot_end_date'] != null) {
      endDate = DateTime.parse(map['timeslot_end_date']);
    }

    return Event(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      timeslot: Daily(
        startDate: DateTime.parse(map['timeslot_start_date']),
        endDate: endDate, // This can be null if timeslot_end_date was not in the map
        frequency: 1, // Assuming a frequency of 1 for Daily since it's not explicitly stored
      ),
      state: EVENT_STATE.values.firstWhere((e) => e.toString() == 'EVENT_STATE.${map['state']}'),
      categoryId: map['category_id'],
    );
  }

}
