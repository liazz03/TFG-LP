import 'package:flutter/material.dart';
import 'package:lifeplanner/src/database/dao/SystemInfo_dao.dart';
import 'package:lifeplanner/src/database/dao/Tasks_dao.dart';
import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/widgets/EventsScreen.dart';
import 'package:lifeplanner/src/widgets/GoalsScreen.dart';
import 'package:lifeplanner/src/widgets/SportsScreen.dart';
import 'package:lifeplanner/src/widgets/TasksScreen.dart';

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

  // Callback function to trigger rebuild of AllItemsWidget
  void _updateItems() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Life Planner'),
          centerTitle: true, 
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
                    ProjectsButton(updateItems: _updateItems),
                    SportsButton(updateItems: _updateItems),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EventsButton(updateItems: _updateItems),
                    JobButton(updateItems: _updateItems),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VacationsButton(updateItems: _updateItems),
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
          await DatabaseHelper.addItem();
          // Trigger rebuild of AllItemsWidget
          updateItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added to database')),
          );
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
          await DatabaseHelper.addItem();
          // Trigger rebuild of AllItemsWidget
          updateItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added to database')),
          );
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
          await DatabaseHelper.addItem();
          // Trigger rebuild of AllItemsWidget
          updateItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added to database')),
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
      color: Color.fromARGB(255, 158, 85, 85),
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to the TasksScreen when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TasksScreen()),
          );
        },
        child: Text('To-Dos'),
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
        onPressed: () async {
          await DatabaseHelper.addItem();
          // Trigger rebuild of AllItemsWidget
          updateItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added to database')),
          );
        },
        child: Text('Habit Tracker'),
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
        onPressed: () async {
          await DatabaseHelper.addItem();
          // Trigger rebuild of AllItemsWidget
          updateItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added to database')),
          );
        },
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
        onPressed: () async {
          await DatabaseHelper.addItem();
          // Trigger rebuild of AllItemsWidget
          updateItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added to database')),
          );
        },
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
      color: Color.fromARGB(255, 158, 85, 85),
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to the GoalsScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GoalsScreen()),
          );
        },
        child: Text('Goals'),
      ),
    );
  }
}


class ProjectsButton extends StatelessWidget {
  final Function updateItems;

  const ProjectsButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          await DatabaseHelper.addItem();
          // Trigger rebuild of AllItemsWidget
          updateItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added to database')),
          );
        },
        child: Text('Projects'),
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
      color: Color.fromARGB(255, 158, 85, 85),
      height: 100,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to the SportsScreen when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SportsScreen()),
          );
        },
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
          // Navigate to the EventsScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventsScreen()),
          );
        },
        child: Text('Events'),
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
          await DatabaseHelper.addItem();
          // Trigger rebuild of AllItemsWidget
          updateItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added to database')),
          );
        },
        child: Text('Job'),
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
        onPressed: () async {
          await DatabaseHelper.addItem();
          // Trigger rebuild of AllItemsWidget
          updateItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added to database')),
          );
        },
        child: Text('Vacations'),
      ),
    );
  }
}


