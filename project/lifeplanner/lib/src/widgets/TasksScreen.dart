import 'package:flutter/material.dart';
import 'package:lifeplanner/src/database/dao/Tasks_dao.dart';
import 'package:lifeplanner/src/modules/Organization/tasks.dart';
import 'package:schedules/schedules.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TasksDao _tasksDao = TasksDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Dos'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddTaskBottomSheet(),
          ),
        ],
      ),
      body: FutureBuilder<List<Tasks>>(
        future: _tasksDao.getAllTasks(), // Fetch tasks from the database
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Tasks> tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.description),
                  subtitle: Text(task.state.toString().split('.').last),
                  trailing: IconButton(
                    icon: Icon(Icons.close,color: Color.fromARGB(255, 163, 21, 10)),
                    onPressed: () => _confirmDeleteTask(task.id),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text("You have no To-Dos!"));
          }
        },
      ),
    );
  }

  void _confirmDeleteTask(int? id) {
    if (id == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                await _tasksDao.deleteTask(id); // Delete the task
                setState(() {}); // Refresh the list of tasks
              },
            ),
          ],
        );
      },
    );
  }



  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bc) {
        return AddTaskForm();
      },
    ).then((value) {
      // Force the widget to rebuild and fetch the tasks again.
      setState(() {});
    });
  }
}

class AddTaskForm extends StatefulWidget {
  @override
  _AddTaskFormState createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  String _description = '';
  final _formKey = GlobalKey<FormState>();
  DateTime? _DeadlineDate;
  TimeOfDay? _deadlineTime;

  DateTime? _TimeslotDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Instantiate TasksDao
  final TasksDao _tasksDao = TasksDao();

  Future<void> _pickDateDeadLine() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _DeadlineDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _DeadlineDate) {
      setState(() {
        _DeadlineDate = picked;
      });
    }
  }

  Future<void> _pickDateTimeSlot() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _TimeslotDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _TimeslotDate) {
      setState(() {
        _TimeslotDate = picked;
      });
    }
  }

  Future<void> _pickDeadlineTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _deadlineTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _deadlineTime) {
      setState(() {
        _deadlineTime = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? (_startTime ?? TimeOfDay.now()),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) { // Add a validator to check the input
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description'; // Return an error message if the input is empty
                  }
                  return null; // Return null if the input is valid
                },
                onSaved: (value) {
                  _description = value ?? '';
                },
            ),
            SizedBox(height: 10),
            // Section to pick a date for the deadline or timeslot
            ElevatedButton(
              onPressed: _pickDateDeadLine,
              child: Text(_DeadlineDate == null
                  ? 'Select Deadline Date'
                  : 'Deadline date: ${_DeadlineDate!.toLocal().toString().split(' ')[0]}'),
            ),
            SizedBox(height: 10),
            // Section to pick a deadline time
            ElevatedButton(
              onPressed: _DeadlineDate == null ? null : _pickDeadlineTime,
              child: Text(_deadlineTime == null
                  ? 'Select Deadline Time'
                  : 'Deadline Time: ${_deadlineTime!.format(context)}'),
            ),
            SizedBox(height: 10),
            // Section to pick a date for timeslot
            ElevatedButton(
              onPressed: _pickDateTimeSlot,
              child: Text(_TimeslotDate == null
                  ? 'Select Date for doing this task'
                  : 'Date of doing: ${_TimeslotDate!.toLocal().toString().split(' ')[0]}'),
            ),
            SizedBox(height: 10),
            // Section to pick a start time for the timeslot
            ElevatedButton(
              onPressed: _TimeslotDate == null ? null : _pickStartTime,
              child: Text(_startTime == null
                  ? 'Select Timeslot Start Time'
                  : 'Start Time: ${_startTime!.format(context)}'),
            ),
            SizedBox(height: 10),
            // Section to pick an end time for the timeslot
            ElevatedButton(
              onPressed: _TimeslotDate == null || _startTime == null ? null : _pickEndTime,
              child: Text(_endTime == null
                  ? 'Select Timeslot End Time'
                  : 'End Time: ${_endTime!.format(context)}'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Add Task'),
              onPressed: () {
                  if (_formKey.currentState!.validate()) { // Check if the form is valid
                    _formKey.currentState!.save();
                    _addTask();
                    Navigator.pop(context); // Close the bottom sheet
                  }
              },
            ),
          ],
        ),

      )
      
    );
  }

  void _addTask() async {
    DateTime? deadlineDateTime;
    if (_DeadlineDate != null && _deadlineTime != null) {
      deadlineDateTime = DateTime(
        _DeadlineDate!.year,
        _DeadlineDate!.month,
        _DeadlineDate!.day,
        _deadlineTime!.hour,
        _deadlineTime!.minute,
      );
    }

    Schedule? timeslot;
    if (_TimeslotDate != null && _startTime != null && _endTime != null) {
      final DateTime startDateTime = DateTime(
        _TimeslotDate!.year,
        _TimeslotDate!.month,
        _TimeslotDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final DateTime endDateTime = DateTime(
        _TimeslotDate!.year,
        _TimeslotDate!.month,
        _TimeslotDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );
      // Assuming Schedule can be constructed like this, adjust according to your Schedule class
      timeslot = Daily(startDate: startDateTime, endDate: endDateTime, frequency: 0); // Update this line as per your Schedule class implementation
    }

    final Tasks newTask = Tasks(
      state: TASKS_STATE.PENDING,
      deadline: deadlineDateTime,
      description: _description,
      timeslot: timeslot,
    );

    await _tasksDao.addTask(newTask);

  }

}
