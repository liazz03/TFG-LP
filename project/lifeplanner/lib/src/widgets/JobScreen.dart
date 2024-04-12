
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/Incomes_dao.dart';
import 'package:lifeplanner/src/database/dao/Jobs_dao.dart';
import 'package:lifeplanner/src/modules/Finance/income.dart';
import 'package:lifeplanner/src/modules/Job/job.dart';
import 'package:lifeplanner/src/modules/Organization/Schedule_def.dart';
import 'package:schedules/schedules.dart';

class JobsScreen extends StatefulWidget {
  @override
  _JobsScreenState createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final JobsDao _jobsDao = JobsDao();
  final IncomesDao _incomesDao = IncomesDao();
  final _formKey = GlobalKey<FormState>(); // Form key

  // form data
  String _jobName = '';
  List<Weekly> _weeklySchedule = [];
  JobType? selectedJobType; 

  // income form
  double _amount = 0.0; 
  bool _budgetOrNot = false; 
  DateTime _incomeDate = DateTime.now(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            iconSize: 30, 
            onPressed: () => _showAddJobSheet(), 
          ),
        ],
      ),
      body: FutureBuilder<List<Job>>(
        future: _jobsDao.getallJobs(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Job> jobs = snapshot.data!;
            return ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return ListTile(
                  title: Text(job.name),  
                  subtitle: Text("Hours per week: ${job.total_hours}\n"
                      "${job.type.toString().split('.').last}\n"
                      "${job.schedule?.asString()}\n"), 
                      
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Funcionalidad para editar el trabajo
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Color.fromARGB(255, 163, 21, 10)),
                        onPressed: () => _confirmDeleteJob(job.id), 
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            );
          } else {
            return Center(child: Text("No jobs found!"));
          }
        },
      ),
    );
  }


void _showAddJobSheet() {

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Add New Job', style: Theme.of(context).textTheme.headline6),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Job Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a job name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _jobName = value!;
                  },
                ),
                DropdownButtonFormField<JobType>(
                  value: selectedJobType,
                  decoration: InputDecoration(labelText: 'Job Type'),
                  items: JobType.values.map((JobType type) {
                    return DropdownMenuItem<JobType>(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (JobType? newValue) {
                    selectedJobType = newValue;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a job type';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                    onPressed: _addTimeSlot,
                    child: Text('Add Time Slot'),
                  ),
                ..._weeklySchedule.map((weekly) {
                  return Column(
                    children: [
                      Text('${DateFormat('EEEE').format(weekly.startDate)} - ${DateFormat('jm').format(weekly.startDate)} to ${DateFormat('jm').format(weekly.endDate!)}'),
                      // This button could be used to remove a time slot, you'll need to implement the logic for removing
                    ],
                  );
                }).toList(),
                SizedBox(height: 10),
                Text('Add Job Income', style: Theme.of(context).textTheme.headlineSmall),   
                TextFormField(
                  decoration: InputDecoration(labelText: 'Income Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _amount = double.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Income Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(text: DateFormat('yyyy-MM-dd').format(_incomeDate)), 
                  readOnly: true, 
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _incomeDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _incomeDate) {
                      setState(() {
                        _incomeDate = pickedDate;
                      });
                    }
                  },
                ),
                SwitchListTile(
                  title: Text('Budgeted'),
                  value: _budgetOrNot,
                  onChanged: (bool value) {
                    setState(() {
                      _budgetOrNot = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _addJob();
                    }
                  },
                  child: Text('Save Job'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).then((_) {
      _formKey.currentState?.reset();
      _weeklySchedule.clear();
      _amount = 0.0; 
      _budgetOrNot = false; 
      _incomeDate = DateTime.now(); 
    });
}

Future<void> _addJob() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    // Instance Income
    final Income newIncome = Income(
      date: _incomeDate, 
      amount: _amount, 
      concept: _jobName, // Job name by default
      budget_or_not: _budgetOrNot, 
      budgetCategory: '', // TODO
    );

    // add income to db
    final int incomeId = await _incomesDao.addIncome(newIncome);

    // fetch income from db
    final Income? savedIncome = await _incomesDao.getIncomeById(incomeId);
    if (savedIncome == null) {
      print('Error saving income');
      return;
    }

    // calculate total hours
    int _totalHours = 0;
    for (Weekly weeklySlot in _weeklySchedule) {
      DateTime startDate = weeklySlot.startDate;
      DateTime? endDate = weeklySlot.endDate;
      int startMinutes = startDate.hour * 60 + startDate.minute;
      int endMinutes = endDate!.hour * 60 + endDate.minute;
      int durationMinutes = endMinutes - startMinutes;
      double durationHours = durationMinutes / 60;
      _totalHours += durationHours.round(); 
    }

    // Instance job with valid income
    Schedule_def _schedule = Schedule_def(schedule: _weeklySchedule);

    final Job newJob = Job(
      name: _jobName,
      schedule: _schedule, 
      type: selectedJobType!, 
      total_hours: _totalHours, 
      income: savedIncome, 
    );

    // sabe job in db
    final int jobId = await _jobsDao.addJob(newJob);
    if (jobId > 0) {
      Navigator.pop(context);
      setState(() {}); 
    } else {
      print('Error saving job');
    }
  }
}



Future<void> _addTimeSlot() async {
    // user pick a day of the week
    final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String? selectedDay = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select a day'),
          children: daysOfWeek.map((String day) {
            return SimpleDialogOption(
              onPressed: () { Navigator.pop(context, day); },
              child: Text(day),
            );
          }).toList(),
        );
      },
    );

    if (selectedDay == null) return;
    int weekday = daysOfWeek.indexOf(selectedDay) + 1; // Convert day to integer

    // Pick the start time
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (startTime == null) return; 

    // Pick the end time
    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (startTime.hour + 1) % 24, minute: startTime.minute),
    );
    if (endTime == null) return; 

    // Convert TimeOfDay to DateTime
    final now = DateTime.now();
    final DateTime startDate = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
    final DateTime endDate = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

    setState(() {
      _weeklySchedule.add(Weekly(
        startDate: startDate,
        endDate: endDate,
        weekdays: [weekday], 
        frequency: 1, // Assuming frequency is always 1 
      ));
    });
  }

  void _confirmDeleteJob(int? id) {
    if (id == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Job'),
          content: Text('Are you sure you want to delete this job?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _jobsDao.deleteJob(id);
                Navigator.of(context).pop(); 
                setState(() {}); 
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("job deleted successfully.")));
              },
            ),
          ],
        );
      },
    );
  }

}