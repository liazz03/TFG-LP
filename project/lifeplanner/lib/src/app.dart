import 'package:flutter/material.dart';
import 'package:lifeplanner/src/database/local_db_helper.dart';
import 'package:lifeplanner/src/widgets/GoalsScreen.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
                SizedBox(height: 20),
                Container(
                  width: 300, // Adjust width as needed
                  height: 200, // Adjust height as needed
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AllItemsWidget(),
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
        onPressed: () async {
          await DatabaseHelper.addItem();
          // Trigger rebuild of AllItemsWidget
          updateItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added to database')),
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

class AllItemsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.getAllItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No items found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return ListTile(
                title: Text(item['name'].toString()),
                // Other item properties can be displayed here
              );
            },
          );
        }
      },
    );
  }
}

