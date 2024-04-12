import 'package:flutter/material.dart';
import 'package:lifeplanner/src/database/dao/HabitTracker_dao.dart';
import 'package:lifeplanner/src/modules/Organization/habittracker.dart';

class HabitTrackerScreen extends StatefulWidget {
  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final double cellWidth = 80.0;
  final double cellHeight = 40.0;
  HabitTracker? currentHabitTracker;
  final HabitTrackerDao _habitTrackerDao = HabitTrackerDao();

  @override
  void initState() {
    super.initState();
    _initializeOrGetHabitTracker();
  }

  void _initializeOrGetHabitTracker() async {
    final DateTime now = DateTime.now();
    final Month currentMonth = Month.values[now.month - 1];
    final int currentYear = now.year;
    HabitTracker? habitTracker = await _habitTrackerDao.getHabitTrackerByMonthAndYear(currentMonth, currentYear);

    if (habitTracker == null) {
      habitTracker = HabitTracker(month: currentMonth, year: currentYear, habits: []);
      await _habitTrackerDao.addHabitTracker(habitTracker);
    }

    setState(() {
      currentHabitTracker = habitTracker;
    });
  }

  List<DataRow> _createTableRows() {
    int daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day; 

    return List.generate(daysInMonth, (index) {
      final dayNumber = index + 1;

      List<DataCell> habitCells = currentHabitTracker!.habits.map((habit) {
        bool isCompleted = habit.completedDates.contains(dayNumber);
        return DataCell(
          InkWell(
            onTap: () {
              setState(() {
                if (isCompleted) {
                  habit.completedDates.remove(dayNumber);
                } else {
                  habit.completedDates.add(dayNumber);
                }
                _habitTrackerDao.updateHabitTracker(currentHabitTracker!);  // Assuming this method exists to handle updates
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(width: 0.5, color: Colors.grey),
                  left: BorderSide(width: 0.5, color: Colors.grey),
                  bottom: BorderSide(width: 0.5, color: Colors.grey),
                ),
                color: isCompleted ? Colors.green : Colors.transparent,
              ),
              width: cellWidth,
              height: cellHeight,
            ),
          ),
        );
      }).toList();

      habitCells.insert(
        0,
        DataCell(
          Container(
            width: cellWidth,
            height: cellHeight,
            child: Center(child: Text('$dayNumber')),
          ),
        ),
      );

      return DataRow(cells: habitCells);
    });
  }

  void _addNewHabit() async {
    TextEditingController _habitNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Habit'),
          content: TextField(
            controller: _habitNameController,
            decoration: InputDecoration(hintText: "Enter habit name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (_habitNameController.text.isNotEmpty) {
                  setState(() {
                    Habit newHabit = Habit(name: _habitNameController.text, completedDates: []);
                    currentHabitTracker!.habits.add(newHabit);
                    _habitTrackerDao.updateHabitTracker(currentHabitTracker!);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editHabits() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...currentHabitTracker!.habits.map((habit) {
                    TextEditingController textEditingController = TextEditingController(text: habit.name);
                    return ListTile(
                      title: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(labelText: "Edit habit name"),
                        onChanged: (value) => setModalState(() => habit.name = value),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => setModalState(() {
                          currentHabitTracker!.habits.remove(habit);
                        }),
                      ),
                    );
                  }).toList(),
                  ElevatedButton(
                    child: Text("Save Changes"),
                    onPressed: () {
                      setState(() {
                        _habitTrackerDao.updateHabitTracker(currentHabitTracker!);
                      });
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Habit Tracker"),
        actions: <Widget>[
          IconButton(
            iconSize: 30, 
            icon: Icon(Icons.add),
            onPressed: _addNewHabit,
          ),
          IconButton(
            icon: Icon(Icons.edit),
            iconSize: 30,
            onPressed: _editHabits,
          ),
        ],
      ),
      body: currentHabitTracker == null ? CircularProgressIndicator() : Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(width: cellWidth), 
                ...currentHabitTracker!.habits.map((habit) {
                  return Container(
                    color: Colors.white,
                    width: cellWidth,
                    height: cellHeight,
                    child: Center(child: Text(habit.name)),
                  );
                }).toList(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 0,
                  dataRowHeight: cellHeight,
                  headingRowHeight: 0,
                  columns: [
                    DataColumn(label: Container(width: cellWidth)),
                    ...currentHabitTracker!.habits.map((_) => DataColumn(label: Container(width: cellWidth))),
                  ],
                  rows: _createTableRows(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
