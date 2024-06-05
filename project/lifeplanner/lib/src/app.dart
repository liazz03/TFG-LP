import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/SystemInfo_dao.dart';
import 'package:lifeplanner/src/widgets/AcademicsScreen.dart';
import 'package:lifeplanner/src/widgets/EventsScreen.dart';
import 'package:lifeplanner/src/widgets/FinanceScreen.dart';
import 'package:lifeplanner/src/widgets/GoalsScreen.dart';
import 'package:lifeplanner/src/widgets/HabitTrackerScreen.dart';
import 'package:lifeplanner/src/widgets/JobScreen.dart';
import 'package:lifeplanner/src/widgets/MonthlyCalendarScreen.dart';
import 'package:lifeplanner/src/widgets/SportsScreen.dart';
import 'package:lifeplanner/src/widgets/TasksScreen.dart';
import 'package:lifeplanner/src/widgets/VacationsScreen.dart';
import 'package:lifeplanner/src/widgets/WeeklyPlannerScreen.dart';
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                    EventsButton(updateItems: _updateItems),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FinanceButton(updateItems: _updateItems),
                    AcademicsButton(updateItems: _updateItems),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GoalsButton(updateItems: _updateItems),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WeeklyPlannerScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 167, 205, 236),  
        ),
        child: Text('Weekly Planner',textAlign: TextAlign.center,),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MonthlyCalendarScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 167, 205, 236),  
        ),
        child: Text('Monthly Calendar', textAlign: TextAlign.center,),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 167, 205, 236),  
        ),
        child: Text('Weekly Schedule', textAlign: TextAlign.center,),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 167, 205, 236),  
        ),
        child: Text('To-Dos', textAlign: TextAlign.center),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 236, 196, 167),  
        ),
        child: Text('Habit Tracker',textAlign: TextAlign.center),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 189, 167, 236),  
        ),
        child: Text('Academics'),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 185, 236, 167),  
        ),
        child: Text('Finance'),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 167, 236, 197),  
        ),
        child: Text('Goals'),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 230, 236, 167),  
        ),
        child: Text('Sports'),
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
        child: Text('Events'),
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 232, 167, 236),  
        ),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 236, 167, 167),  
        ),
        child: Text('Jobs'),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), backgroundColor: Color.fromARGB(255, 236, 167, 167),  
        ),
        child: Text('Vacations'),
      ),
    );
  }
}

