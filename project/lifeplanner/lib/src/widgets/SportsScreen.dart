import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/Sports_dao.dart';
import 'package:lifeplanner/src/database/dao/SystemInfo_dao.dart';
import 'package:lifeplanner/src/modules/Activity/sport.dart';
import 'package:lifeplanner/src/modules/Organization/Schedule_def.dart';
import 'package:schedules/schedules.dart';


class SportsScreen extends StatefulWidget {
  @override
  _SportsScreenState createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen> {
  final SportsDao _sportsDao = SportsDao();
  final _formKey = GlobalKey<FormState>(); 

  Future<List<Sport>>? _sportsFuture;

  // Form data
  String _name = '';
  String? _description;
  int _dedicationTimeXWeek = 0;
  List<Weekly> _weeklySchedule = [];

  @override
  void initState() {
    super.initState();
    _loadSports(); 
  }

  void _loadSports() {
    _sportsFuture = _sportsDao.getAllSports();
  }

  void _showAddSportSheet() {
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
                  Text('Create New Sport', style: Theme.of(context).textTheme.headline6),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Sport Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a sport name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    onSaved: (value) {
                      _description = value;
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
                      ],
                    );
                  }).toList(),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Dedicaion time per week (in hours)'),
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _dedicationTimeXWeek = int.parse(value!);
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _saveSport();
                      }
                    },
                    child: Text('Save Sport'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Future<void> _addTimeSlot() async {
    // day of the week
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
    int weekday = daysOfWeek.indexOf(selectedDay) + 1;

    // start time
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (startTime == null) return;

    // end time
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
        frequency: 1, 
      ));
    });
  }

  void _saveSport() async {
    try {
      Schedule_def schedule = Schedule_def(schedule: _weeklySchedule);

      Sport newSport = Sport(
        name: _name,
        description: _description,
        schedule: schedule,
        dedication_time_x_week: _dedicationTimeXWeek,
        actual_dedication_time_x_week: 0,
        total_dedicated_time: 0,
      );

      await _sportsDao.addSport(newSport);
      _weeklySchedule.clear();
      _loadSports();
      Navigator.pop(context); 
      setState(() {}); 
    } catch (e) {
      print('Error adding sport: $e');
    }
  }

  void _confirmDeleteSport(int? sportId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Sport'),
          content: Text('Are you sure you want to delete this sport?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(), 
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); 
                if (sportId != null) {
                  await _sportsDao.deleteSport(sportId); 
                  _loadSports(); 
                  setState(() {}); 
                }
              },
            ),
          ],
        );
      },
    );
  }


  void _showEditSportSheet(Sport sport) {
    // Initialize form
    _name = sport.name;
    _description = sport.description;
    _dedicationTimeXWeek = sport.dedication_time_x_week;
    _weeklySchedule = sport.schedule?.schedule ?? [];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Edit Sport', style: Theme.of(context).textTheme.headline6),
                      TextFormField(
                        initialValue: _name,
                        decoration: InputDecoration(labelText: 'Sport Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a sport name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value!;
                        },
                      ),
                      TextFormField(
                        initialValue: _description,
                        decoration: InputDecoration(labelText: 'Description'),
                        onSaved: (value) {
                          _description = value;
                        },
                      ),
                      TextFormField(
                        initialValue: _dedicationTimeXWeek.toString(),
                        decoration: InputDecoration(labelText: 'Desired dedication time per week (in hours)'),
                        validator: (value) {
                          if (value == null || int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _dedicationTimeXWeek = int.parse(value!);
                        },
                      ),
                      ..._weeklySchedule.map((weekly) {
                        return ListTile(
                          title: Text('${DateFormat('EEEE').format(weekly.startDate)} - ${DateFormat('jm').format(weekly.startDate)} to ${DateFormat('jm').format(weekly.endDate!)}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setModalState(() {
                                _weeklySchedule.remove(weekly);
                              });
                            },
                          ),
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: () => _addTimeSlot(),
                        child: Text('Add Time Slot'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Schedule_def updatedSchedule = Schedule_def(schedule: _weeklySchedule);
                            // Update the sport in the database
                            Sport updatedSport = Sport(
                              id: sport.id,
                              name: _name,
                              description: _description,
                              schedule: updatedSchedule,
                              dedication_time_x_week: _dedicationTimeXWeek,
                              actual_dedication_time_x_week: sport.actual_dedication_time_x_week,
                              total_dedicated_time: sport.total_dedicated_time,
                            );
                            await _sportsDao.updateSport(updatedSport);
                            Navigator.pop(context);
                            setState(() {
                              _loadSports(); // Refresh sports listing
                            });
                          }
                        },
                        child: Text('Update Sport'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _formKey.currentState?.reset();
      _name = '';
      _description = '';
      _dedicationTimeXWeek = 0;
      _weeklySchedule.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_volleyball_outlined, size: 32,),
             SizedBox(width: 8), 
            Text('Sports'),
            
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddSportSheet,
          ),
        ],
      ),
      body: FutureBuilder<List<Sport>>(
        future: _sportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('You have no sports registered!'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final sport = snapshot.data![index];
                double progress = sport.actual_dedication_time_x_week / sport.dedication_time_x_week;
                
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(sport.name),
                      ),
                      SizedBox(width: 8),
                      // Progress bar
                      Container(
                        width: 100, 
                        height: 10, 
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      SizedBox(width: 8), 
                      IconButton(
                        icon: Icon(Icons.access_time, color: Colors.blue),
                        onPressed: () {
                          _showUpdateDedicationTimeDialog(sport);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () => _showEditSportSheet(sport),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _confirmDeleteSport(sport.id),
                      ),
                    ],
                  ),
                  subtitle: Text('${sport.description ?? "No description provided"}\n'
                      'Desired dedication time per week: ${sport.dedication_time_x_week} hours\n'
                      'Dedication time this week: ${sport.actual_dedication_time_x_week} hours\n'
                      'Total dedicated time: ${sport.total_dedicated_time}'),
                  isThreeLine: true,
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _showUpdateDedicationTimeDialog(Sport sport) async {
    final TextEditingController _timeController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Dedication Time'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: 'Enter additional hours'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (int.tryParse(value) == null ) {
                      return 'Please enter a valid number';
                    }
                    if (int.tryParse(value)! <= 0){
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final int additionalHours = int.parse(_timeController.text);
                  sport.actual_dedication_time_x_week += additionalHours;
                  sport.total_dedicated_time += additionalHours;

                  await SportsDao().updateSport(sport);
                  setState(() {
                    // Rebuild the widget to reflect the updated time
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

}
