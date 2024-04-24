import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/SystemInfo_dao.dart';
import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/widgets/AcademicsScreen.dart';
import 'package:lifeplanner/src/widgets/EventsScreen.dart';
import 'package:lifeplanner/src/widgets/FinanceScreen.dart';
import 'package:lifeplanner/src/widgets/GoalsScreen.dart';
import 'package:lifeplanner/src/widgets/HabitTrackerScreen.dart';
import 'package:lifeplanner/src/widgets/JobScreen.dart';
import 'package:lifeplanner/src/widgets/SportsScreen.dart';
import 'package:lifeplanner/src/widgets/TasksScreen.dart';
import 'package:lifeplanner/src/widgets/VacationsScreen.dart';
import 'package:lifeplanner/src/widgets/WeeklyScheduleScreen.dart';


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // OPERATIONS ON INITIALIZATION
  @override
  void initState() {
    super.initState();
    _checkLastEnter();
  }

  Future<void> _checkLastEnter() async {
    SystemInfoDao _systemInfoDao = SystemInfoDao();
    DateTime? lastEnter = await _systemInfoDao.getLastEnterDate();
    DateTime now = DateTime.now();

    if (lastEnter == null ) {
      await _systemInfoDao.setLastEnterDate(now);
    }
  }

  void _updateItems() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Planner',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Life Planner', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  DateFormat('dd/MM').format(DateTime.now()), 
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WeeklyPlannerButton(updateItems: _updateItems),
                    MothlyCalendarButton(updateItems: _updateItems),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WeeklyScheduleButton(updateItems: _updateItems),
                    ToDoButton(updateItems: _updateItems),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HabitTrackerButton(updateItems: _updateItems),
                    AcademicsButton(updateItems: _updateItems),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FinanceButton(updateItems: _updateItems),
                    GoalsButton(updateItems: _updateItems),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EventsButton(updateItems: _updateItems),
                    SportsButton(updateItems: _updateItems),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VacationsButton(updateItems: _updateItems),
                    JobButton(updateItems: _updateItems),
                  ],
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WeeklyPlannerButton extends StatelessWidget {
  final Function updateItems;

  const WeeklyPlannerButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          print("TODO");
        },
        child: Text('Weekly Planner'),
      ),
    );
  }
}

class MothlyCalendarButton extends StatelessWidget {
  final Function updateItems;

  const MothlyCalendarButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
           print("TODO");
        },
        child: Text('Monthly Calendar'),
      ),
    );
  }
}

class WeeklyScheduleButton extends StatelessWidget {
  final Function updateItems;

  const WeeklyScheduleButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WeeklyScheduleScreen()),
          );
        },
        child: Text('Weekly Schedule'),
      ),
    );
  }
}

class ToDoButton extends StatelessWidget {
  final Function updateItems;

  const ToDoButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TasksScreen()),
          );
        },
        child: Text('To-Dos - D'),
      ),
    );
  }
}

class HabitTrackerButton extends StatelessWidget {
  final Function updateItems;

  const HabitTrackerButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HabitTrackerScreen()),
          );
        },
        child: Text('Habit Tracker - D'),
      ),
    );
  }
}

class AcademicsButton extends StatelessWidget {
  final Function updateItems;

  const AcademicsButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AcademicsScreen()),
          );
        },
        child: Text('Academics - D'),
      ),
    );
  }
}

class FinanceButton extends StatelessWidget {
  final Function updateItems;

  const FinanceButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FinanceScreen()),
          );
        },
        child: Text('Finance - D'),
      ),
    );
  }
}

class GoalsButton extends StatelessWidget {
  final Function updateItems;

  const GoalsButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GoalsScreen()),
          );
        },
        child: Text('Goals - D'),
      ),
    );
  }
}


class SportsButton extends StatelessWidget {
  final Function updateItems;

  const SportsButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SportsScreen()),
          );
        },
        child: Text('Sports - D'),
      ),
    );
  }
}


class EventsButton extends StatelessWidget {
  final Function updateItems;

  const EventsButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventsScreen()),
          );
        },
        child: Text('Events - D'),
      ),
    );
  }
}


class JobButton extends StatelessWidget {
  final Function updateItems;

  const JobButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobsScreen()),
          );
        },
        child: Text('Job - D'),
      ),
    );
  }
}

class VacationsButton extends StatelessWidget {
  final Function updateItems;

  const VacationsButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VacationsScreen()),
          );
        },
        child: Text('Vacations - D'),
      ),
    );
  }
}

