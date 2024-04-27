import 'dart:async';

import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';
import 'package:lifeplanner/src/database/dao/Events_dao.dart';
import 'package:lifeplanner/src/database/dao/Subjects_dao.dart';
import 'package:lifeplanner/src/database/dao/Tasks_dao.dart';
import 'package:lifeplanner/src/database/dao/Vacations_dao.dart';
import 'package:lifeplanner/src/modules/Activity/event.dart';
import 'package:lifeplanner/src/modules/Activity/subject.dart';
import 'package:lifeplanner/src/modules/Job/vacation.dart';
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
        title: Text("Monthly Planner"),
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
                        children: eventsOnTheDate
                            .map(
                              (event) => Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(4),
                                margin: const EdgeInsets.only(bottom: 12),
                                color: event.eventBackgroundColor,
                                child: Text(
                                  event.eventName,
                                  style: event.eventTextStyle,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ));
          },
          onPageChanged: (firstDate, lastDate) {
            /// Called when the page was changed
            /// Fetch additional events by using the range between [firstDate] and [lastDate] if you want
          },
              );
            }
          }
      )
    );
  }

  Future<List<CalendarEvent>> getItems() async {

  final tasks = await TasksDao().getAllTasks() ;
  final events = await EventsDao().getAllEvents() ;
  final vacations = await  VacationsDao().getAllVacations() ;
  final subjects = await  SubjectDao().getAllSubjects() ;

  const eventTextStyle = TextStyle(
    fontSize: 12,
    color: Color.fromARGB(255, 0, 0, 0),
  );

  List<CalendarEvent> events_calendar = [];

  for (var task in  tasks){
    if(task.timeslot != null && task.state != TASKS_STATE.COMPLETED){
      events_calendar.add(
        CalendarEvent(
          eventName: task.description,
          eventDate: task.timeslot!.startDate,
          eventBackgroundColor: Color.fromARGB(255, 230, 67, 213),
          eventTextStyle: eventTextStyle,
        ),
      );
    }
  }

  for (var event in events){
    if(event.timeslot != null){
      events_calendar.add(
        CalendarEvent(
          eventName: event.name,
          eventDate: event.timeslot.startDate,
          eventBackgroundColor: Color.fromARGB(255, 93, 208, 164),
          eventTextStyle: eventTextStyle,
        ),
      );
    }
  }

  for (var vacation in vacations){
    events_calendar.add(
      CalendarEvent(
        eventName: vacation.title,
        eventDate: vacation.start_date,
        eventBackgroundColor: Color.fromARGB(255, 84, 144, 211),
        eventTextStyle: eventTextStyle,
      ),
    );
  }

  for (var subject in subjects){
    for( var evaluation in subject.evaluations){
      String name = evaluation.name + " -  " + subject.name; 
      events_calendar.add(
        CalendarEvent(
          eventName: name,
          eventDate: evaluation.date,
          eventBackgroundColor: Color.fromARGB(255, 248, 179, 29),
          eventTextStyle: eventTextStyle,
        ),
      );
    }
  }

  return events_calendar;
}
 }

      
      
      
      

