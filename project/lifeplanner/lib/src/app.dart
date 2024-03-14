import 'package:flutter/material.dart';
import 'package:lifeplanner/src/database/local_db_helper.dart';

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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareButton(updateItems: _updateItems),
                  WeeklyPlannerButton(updateItems: _updateItems),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MothlyCalendarButton(updateItems: _updateItems),
                  WeeklyScheduleButton(updateItems: _updateItems),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToDoButton(updateItems: _updateItems),
                  HabitTrackerButton(updateItems: _updateItems),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AcademicsButton(updateItems: _updateItems),
                  FinanceButton(updateItems: _updateItems),
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
    );
  }
}

class SquareButton extends StatelessWidget {
  final Function updateItems;

  const SquareButton({Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
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
        child: Text('Button add db'),
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
      width: 100,
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
      width: 100,
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
      width: 100,
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
      width: 100,
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
      width: 100,
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
      width: 100,
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
      width: 100,
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

