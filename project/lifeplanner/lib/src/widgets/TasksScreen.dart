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
  void initState() {
    super.initState();
    _markOverdueTasksAsLate(); // Call the method on initState to check tasks every time the screen loads
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Dos'),
        actions: <Widget>[
          IconButton(
            iconSize: 30,
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: const Color.fromARGB(255, 0, 0, 0)),
                      onPressed: () => _showEditTaskSheet(task),
                      ),
                      IconButton(
                    icon: Icon(Icons.check,color: Color.fromARGB(255, 0, 46, 6)),
                    onPressed: () => _MarkAsCompleteTask(task.id),
                      ),
                    IconButton(
                    icon: Icon(Icons.close,color: Color.fromARGB(255, 163, 21, 10)),
                    onPressed: () => _confirmDeleteTask(task.id),
                      ),
                    
                    ],
                  ),
                  isThreeLine: true,
                  
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

  Future<void> _markOverdueTasksAsLate() async {
    await _tasksDao.markOverdueTasksAsLate();
    setState(() {}); 
  }

  void _MarkAsCompleteTask(int? id) async {
    if (id == null) return;

    // Retrieve the task from the database using the id
    Tasks? task = await _tasksDao.getTaskById(id);
    if (task != null) {
      // Update the task's state to COMPLETED
      task.state = TASKS_STATE.COMPLETED;

      // Call the database to update the task
      int result = await _tasksDao.updateTask(task);
      if (result != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task marked as completed')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update the task')),
        );
      }

      // Update the UI
      setState(() {});
    }
  }

  void _showEditTaskSheet(Tasks task) {
    // Create a copy of the task to modify
    Tasks editableTask = Tasks(
      id: task.id,
      state: task.state,
      deadline: task.deadline,
      description: task.description,
      timeslot: task.timeslot,
    );

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              // The form and its fields, similar to AddTaskForm but pre-filled with task data
              // Include logic for handling updates on fields and a submit button to update the task
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: EditTaskForm(editableTask: editableTask, onTaskUpdated: () {
                    setState(() {});
                  }, tasksDao: _tasksDao),
                ),
              );
            },
          );
        },
      ).then((value) {
        // Force widget to rebuild, fetching tasks again
        setState(() {});
      });
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


class EditTaskForm extends StatefulWidget {
  final Tasks editableTask;
  final VoidCallback onTaskUpdated;
  final TasksDao tasksDao; 

  EditTaskForm({
    Key? key,
    required this.editableTask,
    required this.onTaskUpdated,
    required this.tasksDao, 
  }) : super(key: key);

  @override
  _EditTaskFormState createState() => _EditTaskFormState();
}


class _EditTaskFormState extends State<EditTaskForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late DateTime? _deadline;
  late DateTime? _dateOfDoing;
  late TASKS_STATE _taskState;
  TimeOfDay? _startTime_dateofdoing;
  TimeOfDay? _endTime_dateofdoing;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.editableTask.description);
    _deadline = widget.editableTask.deadline;
    _taskState = widget.editableTask.state;

    _dateOfDoing = widget.editableTask.timeslot?.startDate; // Assuming you want to edit an existing timeslot
    // If timeslot has start and end times, initialize them here as well
    _startTime_dateofdoing = TimeOfDay.fromDateTime(widget.editableTask.timeslot?.startDate ?? DateTime.now());
    _endTime_dateofdoing = TimeOfDay.fromDateTime(widget.editableTask.timeslot?.endDate ?? DateTime.now());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

   Future<void> _pickDeadlineDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _deadline) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _pickTimeslotStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfDoing ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dateOfDoing) {
      setState(() => _dateOfDoing = picked);
    }
  }

  Future<void> _pickTimeslotStartTime() async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: _startTime_dateofdoing ?? TimeOfDay.now(),
  );
  if (picked != null && picked != _startTime_dateofdoing) {
    setState(() => _startTime_dateofdoing = picked);
  }
}

Future<void> _pickTimeslotEndTime() async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: _endTime_dateofdoing ?? TimeOfDay.now(),
  );
  if (picked != null && picked != _endTime_dateofdoing) {
    setState(() => _endTime_dateofdoing = picked);
  }
  }

  void _updateTask() async {
      if (_formKey.currentState!.validate()) {
        // Update task description
        widget.editableTask.description = _descriptionController.text;
        widget.editableTask.deadline = _deadline; // Set the new deadline

        // Check if we have both date and time for the timeslot
        if (_dateOfDoing != null && _startTime_dateofdoing != null && _endTime_dateofdoing != null) {
          // Combine date and time for startDateTime
          DateTime startDateTime = DateTime(
            _dateOfDoing!.year,
            _dateOfDoing!.month,
            _dateOfDoing!.day,
            _startTime_dateofdoing!.hour,
            _startTime_dateofdoing!.minute,
          );

          // Combine date and time for endDateTime
          DateTime endDateTime = DateTime(
            _dateOfDoing!.year,
            _dateOfDoing!.month,
            _dateOfDoing!.day,
            _endTime_dateofdoing!.hour,
            _endTime_dateofdoing!.minute,
          );

          widget.editableTask.timeslot = Daily(
            startDate: startDateTime,
            endDate: endDateTime,
            frequency: 0, // Assuming frequency is 0 for a single occurrence
          );
        }

        // Call the DAO to update the task in the database
        int result = await widget.tasksDao.updateTask(widget.editableTask);
        if (result != 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task updated successfully')));
          widget.onTaskUpdated(); // Refresh the list of tasks
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update the task')));
        }

        Navigator.pop(context); // Close the modal bottom sheet
      }
  }

  @override
  Widget build(BuildContext context) {
    // Check if task is editable
    bool isEditable = _taskState != TASKS_STATE.COMPLETED;

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (!isEditable) // If the task is not editable, show a red text message
            Text(
              'This task is not editable because its completed.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Edit description'),
              enabled: isEditable,
            ),
            ElevatedButton(
              onPressed: isEditable ? _pickDeadlineDate : null,
              child: Text(_deadline == null ? 'Pick a new deadline' : 'Deadline: $_deadline'),
            ),
            ElevatedButton(
              onPressed: isEditable ? _pickTimeslotStartDate : null,
              child: Text(_dateOfDoing == null ? 'Pick new date of doing this task' : 'Start: $_dateOfDoing'),
            ),
            if (_dateOfDoing != null) ...[
              ElevatedButton(
                onPressed: isEditable ? _pickTimeslotStartTime : null,
                child: Text(_startTime_dateofdoing != null ? 'Start Time: ${_startTime_dateofdoing!.format(context)}' : 'Select Start Time'),
              ),
              ElevatedButton(
                onPressed: isEditable ? _pickTimeslotEndTime : null,
                child: Text(_endTime_dateofdoing != null ? 'End Time: ${_endTime_dateofdoing!.format(context)}' : 'Select End Time'),
              ),
            ],
            ElevatedButton(
              child: Text('Update Task'),
              onPressed: isEditable ? _updateTask : null,
            ),
          ],
        ),
      ),
    );
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
                  : 'From: ${_startTime!.format(context)}'),
            ),
            SizedBox(height: 10),
            // Section to pick an end time for the timeslot
            ElevatedButton(
              onPressed: _TimeslotDate == null || _startTime == null ? null : _pickEndTime,
              child: Text(_endTime == null
                  ? 'Select Timeslot End Time'
                  : 'To: ${_endTime!.format(context)}'),
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
