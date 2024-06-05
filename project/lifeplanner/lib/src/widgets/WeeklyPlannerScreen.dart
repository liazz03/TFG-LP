import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/Events_dao.dart';
import 'package:lifeplanner/src/database/dao/Sports_dao.dart';
import 'package:lifeplanner/src/database/dao/Subjects_dao.dart';
import 'package:lifeplanner/src/modules/Activity/event.dart';

import '../modules/Activity/sport.dart';
import '../modules/Activity/subject.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  @override
    _WeeklyPlannerScreenState createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {

  List<Subject> subjects = [];
  List<Sport> sports = [];
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    List<Subject> allSubjects = await SubjectDao().getAllSubjects();
    List<Sport> allSports = await SportsDao().getAllSports(); 
    events = await EventsDao().getAllEvents(); 

    subjects = allSubjects.where((subject) => subject.schedule != null).toList();
    sports =  allSports.where((sport) => sport.schedule != null).toList();

    setState(() {});
  }

  List<String> _getWeekDates() {
    DateTime now = DateTime.now();
    int currentDayOfWeek = now.weekday;
    DateTime startOfWeek = now.subtract(Duration(days: currentDayOfWeek - 1));
    return List.generate(7, (index) => DateFormat('dd/MM EEEE').format(startOfWeek.add(Duration(days: index))));
  }

  @override
  Widget build(BuildContext context) {
    List<String> weekDates = _getWeekDates();

    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Planner'),
      ),
      body: ListView.builder(
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          DateTime day = DateFormat('dd/MM EEEE').parse(weekDates[index]);
          var daySubjects = subjects.where((s) => s.schedule!.schedule.any((w) => w.weekdays.contains(day.weekday))).toList();
          var daySports = sports.where((s) => s.schedule!.schedule.any((w) => w.weekdays.contains(day.weekday))).toList();
          var dayEvents = events.where((e) => e.timeslot.startDate.day == day.day && e.timeslot.startDate.month == day.month).toList();

          return Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 150.0),
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 2,
                  blurRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weekDates[index], style: TextStyle(fontWeight: FontWeight.bold)),
                ...daySubjects.map((s) => Text('Subject: ${s.name}', style: TextStyle(fontSize: 16))),
                ...daySports.map((s) => Text('Sport: ${s.name}', style: TextStyle(fontSize: 16))),
                ...dayEvents.map((e) => Text('Event: ${e.name}', style: TextStyle(fontSize: 16))),
              ],
            ),
          );
        },
      ),
    );
  }
}