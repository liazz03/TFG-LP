import 'package:flutter/material.dart';
import 'package:lifeplanner/src/database/dao/Events_dao.dart';
import 'package:lifeplanner/src/database/dao/Jobs_dao.dart';
import 'package:lifeplanner/src/database/dao/Sports_dao.dart';
import 'package:lifeplanner/src/database/dao/Subjects_dao.dart';
import 'package:lifeplanner/src/database/dao/Tasks_dao.dart';
import 'package:schedules/schedules.dart';


class WeeklyScheduleScreen extends StatefulWidget {
  @override
  _WeeklyScheduleScreenState createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
    
  final daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  Map<int, List<dynamic>> activitiesByTimeSlot = {};

  @override
  void initState() {
    super.initState();
    fetchAllActivities();
  }

  void fetchAllActivities() async {
    final sports = await SportsDao().getAllSports();
    final subjects = await SubjectDao().getAllSubjects();
    final jobs = await JobsDao().getallJobs();

    for (int i = 6; i <= 23; i++) {
      activitiesByTimeSlot[i] = List.generate(7, (_) => []);
    }

    for (var sport in sports) {
      if (sport.schedule != null) {
        for (var weekly in sport.schedule!.schedule) {
          for (var weekday in weekly.weekdays) {
            insertActivity(sport, weekly, weekday);
          }
        }
      }
    }

    for (var subject in subjects) {
      if (subject.schedule != null) {
        for (var weekly in subject.schedule!.schedule) {
          for (var weekday in weekly.weekdays) {
            insertActivity(subject, weekly, weekday);
          }
        }
      }
    }

    for (var job in jobs) {
      if (job.schedule != null) {
        for (var weekly in job.schedule!.schedule) {
          for (var weekday in weekly.weekdays) {
            insertActivity(job, weekly, weekday);
          }
        }
      }
    }

    setState(() {});
  }

  void insertActivity(dynamic activity, Weekly weekly, int weekday) {
  int startHour = weekly.startDate.hour; // Start hour of the activity
  int endHour = weekly.endDate?.hour ?? startHour + 1; 
  int dayIndex = weekday - 1; 

  for (int hour = startHour; hour < endHour; hour++) {
    activitiesByTimeSlot[hour]![dayIndex].add(activity);
  }
}


  @override
  Widget build(BuildContext context) {
    // dimensions for the cells
    const double hourColumnWidth = 48.0;
    const double dayColumnWidth = 100.0;
    const double cellHeight = 36.9;
    const double headerHeight = 40.0;
    const double fontSize = 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 30,),
             SizedBox(width: 8), 
            Text('Weekly Schedule'),
            
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            columnWidths: {
              0: FixedColumnWidth(hourColumnWidth), 
              for (int day = 1; day <= daysOfWeek.length; day++)
                day: FixedColumnWidth(dayColumnWidth), 
            },
            border: TableBorder.all(),
            children: [
              // Header row
              TableRow(
                children: [
                  TableCell(
                    child: Container(
                      height: headerHeight,
                      alignment: Alignment.center,
                      child: Text('Hour', style: TextStyle(fontSize: fontSize)),
                      color: Color.fromARGB(255, 152, 214, 209),
                    ),
                  ),
                  ...daysOfWeek.map((day) => TableCell(
                    child: Container(
                      height: headerHeight,
                      alignment: Alignment.center,
                      child: Text(day, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize)),
                      color:  Color.fromARGB(255, 106, 189, 182),
                    ),
                  )).toList(),
                ],
              ),
              // Hour rows
              ...List.generate(18, (rowIndex) {
                return TableRow(
                  children: List.generate(daysOfWeek.length + 1, (columnIndex) {
                    if (columnIndex == 0) {
                      // First column for hours
                      return TableCell(
                        child: Container(
                          height: cellHeight,
                          alignment: Alignment.center,
                          child: Text('${6 + rowIndex}:00', style: TextStyle(fontSize: fontSize)),
                        ),
                      );
                    } else {
                      // cell contents
                      List<Widget> activitiesForThisSlot = activitiesByTimeSlot[6 + rowIndex]![columnIndex - 1].map<Widget>((activity) {
                        return Text(activity.name, style: TextStyle(fontSize: fontSize)); 
                      }).toList();
                      return TableCell(
                        child: Container(
                          height: cellHeight,
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            child: Column(
                              children: activitiesForThisSlot.isEmpty ? [Text('')] : activitiesForThisSlot,
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
