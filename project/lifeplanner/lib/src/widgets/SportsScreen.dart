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
  final _formKey = GlobalKey<FormState>(); // Form key

  Future<List<Sport>>? _sportsFuture;

  // Form data
  String _name = '';
  String? _description;
  int _dedicationTimeXWeek = 0;
  List<Weekly> _weeklySchedule = [];

  @override
  void initState() {
    super.initState();
    _checkAndUpdateDedication();
    _loadSports(); // Load sports after updating dedication times
  }

  Future<void> _checkAndUpdateDedication() async {
    SystemInfoDao _systemInfoDao = SystemInfoDao();
    DateTime? lastEnter = await _systemInfoDao.getLastEnterDate();
    DateTime now = DateTime.now();
    DateTime aWeekAgo = now.subtract(Duration(days: 7));

    if (lastEnter!.isBefore(aWeekAgo)) {
      // update and reset
      await _sportsDao.resetCurrentDedicationAndUpdateTotal();
    }else{
      // just update
      await _sportsDao.UpdateTotal();
    }
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
                        // This button could be used to remove a time slot, you'll need to implement the logic for removing
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
    // Step 1: Let the user pick a day of the week
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

    if (selectedDay == null) return; // User canceled or didn't pick a day
    int weekday = daysOfWeek.indexOf(selectedDay) + 1; // Convert day to integer (1 = Monday, ..., 7 = Sunday)

    // Step 2: Pick the start time
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (startTime == null) return; // User canceled

    // Step 3: Pick the end time
    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (startTime.hour + 1) % 24, minute: startTime.minute),
    );
    if (endTime == null) return; // User canceled

    // Convert TimeOfDay to DateTime
    final now = DateTime.now();
    final DateTime startDate = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
    final DateTime endDate = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

    setState(() {
      _weeklySchedule.add(Weekly(
        startDate: startDate,
        endDate: endDate,
        weekdays: [weekday], // Adding the selected day as a single-element list
        frequency: 1, // Assuming frequency is always 1 for simplicity
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
      _weeklySchedule.clear(); // clear schedule 
      _loadSports();
      Navigator.pop(context); // Dismiss the modal bottom sheet
      setState(() {}); // This triggers the UI to refresh.
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
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                if (sportId != null) {
                  await _sportsDao.deleteSport(sportId); // Delete the sport
                  _loadSports(); // Refresh the list of sports
                  setState(() {}); // Trigger a rebuild
                }
              },
            ),
          ],
        );
      },
    );
  }


  void _showEditSportSheet(Sport sport) {
    // Initialize form with sport's current values
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
                        decoration: InputDecoration(labelText: 'Dedication Time x Week'),
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
                            Navigator.pop(context); // Close the modal bottom sheet
                            setState(() {
                              _loadSports(); // Refresh the list of sports
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
      // Reset form and local state after the modal is dismissed
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
      title: Text('Sports'),
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
                      // Wrap title in an Expanded to ensure it takes up remaining space
                      child: Text(sport.name),
                    ),
                    SizedBox(width: 8), // Add some spacing between title and progress bar
                    // Progress bar
                    Container(
                      width: 100, // Width of the progress bar
                      height: 10, // Height of the progress bar
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    SizedBox(width: 8), // Add some spacing between progress bar and icons
                    // Icons
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


}
