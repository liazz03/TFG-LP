import 'dart:async';

import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';
import 'package:lifeplanner/src/database/dao/Events_dao.dart';
import 'package:lifeplanner/src/database/dao/Subjects_dao.dart';
import 'package:lifeplanner/src/database/dao/Tasks_dao.dart';
import 'package:lifeplanner/src/database/dao/Vacations_dao.dart';
import 'package:calendarific_dart/calendarific_dart.dart';
import 'package:lifeplanner/src/modules/Organization/tasks.dart';

class MonthlyCalendarScreen extends StatefulWidget {
  @override
  _MonthlyCalendarScreenState createState() => _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends State<MonthlyCalendarScreen>{
  
  @override
  Widget build(BuildContext context) {
    final cellCalendarPageController = CellCalendarPageController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly Calendar"),
      ),
      body: FutureBuilder<List<CalendarEvent>>(
          future: getItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return CellCalendar(
          cellCalendarPageController: cellCalendarPageController,
          events: snapshot.data!,
          daysOfTheWeekBuilder: (dayIndex) {
            final labels = ["S", "M", "T", "W", "T", "F", "S"];
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                labels[dayIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
          monthYearLabelBuilder: (datetime) {
            final year = datetime!.year.toString();
            final month = datetime.month.monthName;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Text(
                    "$month  $year",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      print("TODO add activity implementation");
                    },
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      cellCalendarPageController.animateToDate(
                        DateTime.now(),
                        curve: Curves.linear,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                  )
                ],
              ),
            );
          },
            onCellTapped: (date) {
              final eventsOnTheDate = snapshot.data!.where((event) {
              final eventDate = event.eventDate;
              return eventDate.year == date.year &&
                    eventDate.month == date.month &&
                    eventDate.day == date.day;
            }).toList(); 

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text("${date.month.monthName} ${date.day}"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: eventsOnTheDate.map((event) {
                    if (event is ExtendedCalendarEvent) {
                      return ListTile(
                        tileColor: event.eventBackgroundColor,
                        title: Text(event.eventName, style: event.eventTextStyle),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            if (event.itemType == ItemType.Holiday){
                              snapshot.data!.remove(event);
                            }else{
                              _deleteEvent(event);
                            }
                        },
                        ),
                      );
                    } else {
                      return ListTile(
                        title: Text(event.eventName, style: event.eventTextStyle),
                        subtitle: Text(''),
                      );
                    }
                  }).toList(),
                ),
              ));
              },
            onPageChanged: (firstDate, lastDate) {
              /// Called when the page was changed
            },
                );
              }
            }
        )
      );
  }

  void _deleteEvent(ExtendedCalendarEvent event) {
    switch (event.itemType) {
      case ItemType.Task:
        TasksDao().deleteTask(event.id);
        break;
      case ItemType.Event:
        EventsDao().deleteEvent(event.id);
        break;
      case ItemType.Vacation:
        VacationsDao().deleteVacation(event.id);
        break;
      case ItemType.Subject:
        SubjectDao().deleteSubject(event.id);
        break;
      case ItemType.Holiday:
        break;
    }
    setState((){Navigator.pop(context);});
  }

  Future<List<CalendarEvent>> getItems() async {
  const String apiKey = '7TbFJdwtL9Bq6bK8HUPIdGUrVWYdbinT';
  final CalendarificApi api = CalendarificApi(apiKey);
  final holidays = await api.getHolidays(countryCode: 'ES', year: '2024');

  final tasks = await TasksDao().getAllTasks() ;
  final events = await EventsDao().getAllEvents() ;
  final vacations = await  VacationsDao().getAllVacations() ;
  final subjects = await  SubjectDao().getAllSubjects() ;

  const eventTextStyle = TextStyle(
    fontSize: 12,
    color: Color.fromARGB(255, 0, 0, 0),
  );

  List<CalendarEvent> events_calendar = [];

  if(holidays != null){
    for (var hol in holidays){
      events_calendar.add(
        ExtendedCalendarEvent(
          eventName: hol.name,
          eventDate: hol.date,
          eventBackgroundColor: Color.fromARGB(255, 40, 130, 172),
          eventTextStyle: eventTextStyle,
          id: 0,
          itemType: ItemType.Holiday
        ),
      );
    }
  }
  
  for (var task in  tasks){
    if(task.timeslot != null && task.state != TASKS_STATE.COMPLETED){
      events_calendar.add(
        ExtendedCalendarEvent(
        eventName: task.description,
        eventDate: task.timeslot!.startDate,
        eventBackgroundColor: Color.fromARGB(255, 230, 67, 213),
        eventTextStyle: eventTextStyle,
        id: task.id,
       itemType: ItemType.Task
      ),
      );
    }
  }

  for (var event in events){
    events_calendar.add(
      ExtendedCalendarEvent(
        eventName: event.name,
        eventDate: event.timeslot.startDate,
        eventBackgroundColor: Color.fromARGB(255, 93, 208, 164),
        eventTextStyle: eventTextStyle,
        id: event.id,
        itemType: ItemType.Event
      ),
    );
  }

  for (var vacation in vacations){
    events_calendar.add(
      ExtendedCalendarEvent(
        eventName: vacation.title,
        eventDate: vacation.start_date,
        eventBackgroundColor: Color.fromARGB(255, 84, 144, 211),
        eventTextStyle: eventTextStyle,
        id: vacation.id,
        itemType: ItemType.Vacation
      ),
    );
  }

  for (var subject in subjects){
    for( var evaluation in subject.evaluations){
      String name = evaluation.name + " -  " + subject.name; 
      events_calendar.add(
        ExtendedCalendarEvent(
          eventName: name,
          eventDate: evaluation.date,
          eventBackgroundColor: Color.fromARGB(255, 248, 179, 29),
          eventTextStyle: eventTextStyle,
          id: subject.id,
          itemType: ItemType.Subject
        ),
      );
    }
  }

  return events_calendar;
}
 }

enum ItemType {Task, Event, Vacation, Subject, Holiday,}

class ExtendedCalendarEvent extends CalendarEvent {
  final int id; // Non-nullable integer
  final ItemType itemType;

  ExtendedCalendarEvent({
    required String eventName,
    required DateTime eventDate,
    required Color eventBackgroundColor,
    required TextStyle eventTextStyle,
    required int? id, // Passed as nullable but checked inside the constructor
    required this.itemType,
  })  : id = id ?? (throw ArgumentError("ID cannot be null")),
        super(
          eventName: eventName,
          eventDate: eventDate,
          eventBackgroundColor: eventBackgroundColor,
          eventTextStyle: eventTextStyle,
        );
}



      
      
      
      

