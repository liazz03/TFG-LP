import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import DateFormat

class WeeklyPlannerScreen extends StatefulWidget {
  @override
    _WeeklyPlannerScreenState createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  List<String> _getWeekDates() {
    DateTime now = DateTime.now();
    int currentDayOfWeek = now.weekday;
    DateTime startOfWeek = now.subtract(Duration(days: currentDayOfWeek - 1));
    return List.generate(7, (index) => DateFormat('dd/MM EEEE').format(startOfWeek.add(Duration(days: index))));
  }

  @override
  Widget build(BuildContext context) {
    List<String> weekDates = _getWeekDates(); // Generate dates for the current week

    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Planner'),
      ),
      body: ListView.builder(
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
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
                Text(
                  weekDates[index],
                  style: TextStyle(
                    fontSize: 18.0,  // Smaller font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Add tasks/events here",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}