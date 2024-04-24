import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/Events_dao.dart';
import 'package:lifeplanner/src/modules/Activity/event.dart';
import 'package:schedules/schedules.dart';


class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventsDao _eventsDao = EventsDao();
  Future<List<Event>>? _eventsFuture;

  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = _eventsDao.getAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event, size: 32,),
             SizedBox(width: 8), 
            Text('Events'),
            
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            iconSize: 30,
            onPressed: _showAddEventSheet,
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading events: ${snapshot.error}'));
          }

          List<Event> allEvents = snapshot.hasData ? snapshot.data! : [];
          List<Event> scheduledEvents = allEvents
              .where((event) => event.state == EVENT_STATE.Scheduled)
              .toList()
            ..sort((a, b) => a.timeslot.startDate.compareTo(b.timeslot.startDate));
          List<Event> finishedEvents = allEvents
              .where((event) => event.state == EVENT_STATE.Finished)
              .toList()
            ..sort((a, b) => a.timeslot.startDate.compareTo(b.timeslot.startDate));

          return ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 3.0, color: Theme.of(context).dividerColor)),
                ),
                child: Text('Upcoming Events', style: Theme.of(context).textTheme.headline6),
              ),
              // if there are scheduled events to display
              if (scheduledEvents.isEmpty)
                ListTile(title: Text('No upcoming events.')),
              ...scheduledEvents.map((event) => ListTile(
                title: Text(event.name),
                subtitle: Text(
                  '${event.description}\n'
                  'Starts: ${DateFormat('MMM d, HH:mm').format(event.timeslot.startDate)}'
                  '${event.timeslot.endDate != null ? '\nEnds: ${DateFormat('MMM d, HH:mm').format(event.timeslot.endDate!)}' : ''}'
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // edit event functionality
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: const Color.fromARGB(255, 151, 18, 9)),
                      onPressed: () => _confirmDeleteEvent(event.id),
                    ),
                  ],
                ),
              )),
              SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 3.0, color: Theme.of(context).dividerColor)),
                ),
                child: Text('Finished Events', style: Theme.of(context).textTheme.headline6),
              ),
              // if there are finished events to display
              if (finishedEvents.isEmpty)
                ListTile(title: Text('No finished events.')),
              ...finishedEvents.map((event) => ListTile(
                title: Text(event.name),
                subtitle: Text(
                  '${event.description}\n'
                  'Starts: ${DateFormat('MMM d, HH:mm').format(event.timeslot.startDate)}'
                  '${event.timeslot.endDate != null ? '\nEnds: ${DateFormat('MMM d, HH:mm').format(event.timeslot.endDate!)}' : ''}'
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: const Color.fromARGB(255, 131, 20, 12)),
                      onPressed: () => _confirmDeleteEvent(event.id),
                    ),
                  ],
                ),
              )),
            ],
          );
        },
      ),
    );
  }




  void _confirmDeleteEvent(int? id) {
    if (id == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); 
                await _eventsDao.deleteEvent(id);
                _loadEvents(); // Refresh the list of events after deletion
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Event deleted successfully.")));
              },
            ),
          ],
        );
      },
    );
  }



  Future<void> _showAddCategoryDialog() async {
    String categoryName = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            onChanged: (value) {
              categoryName = value;
            },
            decoration: InputDecoration(hintText: "Category Name"),
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
              onPressed: () async {
                if (categoryName.isNotEmpty) {
                  await _eventsDao.addCategory(categoryName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddEventSheet() async {
    final categories = await _eventsDao.getAllCategories(); // Fetch categories from the database
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
                  Text('Create New Event', style: Theme.of(context).textTheme.headline6),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Event Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an event name';
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
                      _description = value ?? ''; // Allow optional description
                    },
                  ),
                  // Start Date Picker
                  ListTile(
                    title: Text('Select Start Date'),
                    subtitle: Text(_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'No date chosen'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _pickStartDate(context),
                  ),
                  ListTile(
                    title: Text('Select Start Time'),
                    subtitle: Text(_startTime != null ? _startTime!.format(context) : 'No time chosen'),
                    trailing: Icon(Icons.access_time),
                    onTap: _startDate != null ? () => _pickStartTime(context) : null, // Enabled only after start date is chosen
                  ),
                  ListTile(
                    title: Text('Select End Date'),
                    subtitle: Text(_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'No date chosen'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: _startDate != null ? () => _pickEndDate(context) : null, // Enabled only after start date is chosen
                  ),
                  ListTile(
                    title: Text('Select End Time'),
                    subtitle: Text(_endTime != null ? _endTime!.format(context) : 'No time chosen'),
                    trailing: Icon(Icons.access_time),
                    onTap: _endDate != null ? () => _pickEndTime(context) : null, // Enabled only after end date is chosen
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          hint: Text("Select Category"),
                          value: _selectedCategoryId,
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedCategoryId = newValue!;
                            });
                          },
                          items: categories.map<DropdownMenuItem<int>>((category) {
                            return DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          Navigator.of(context).pop(); 
                          await _showAddCategoryDialog(); 
                          _showAddEventSheet(); 
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _addEvent();
                      }
                    },
                    child: Text('Save Event'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Future<void> _pickStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _startDate) {
      setState(() {
        _startDate = pickedDate;
        _startTime = TimeOfDay(hour: 0, minute: 0); // Reset/start time when date changes
      });
    }
  }


  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _startTime) {
      setState(() {
        _startTime = pickedTime;
      });
    }
  }


  Future<void> _pickEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _endDate) {
      setState(() {
        _endDate = pickedDate;
        _endTime = TimeOfDay(hour: 0, minute: 0); // Reset/start time when date changes
      });
    }
  }


  Future<void> _pickEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _endTime) {
      setState(() {
        _endTime = pickedTime;
      });
    }
  }

  void _addEvent() async {
    // Convertir _startDate y _startTime a un DateTime completo
    DateTime startDateTime = _startDate!;
    if (_startTime != null) {
      startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    }

    // Convertir _endDate y _endTime a un DateTime completo (opcionalmente considerando todo el día si _endTime es nulo)
    DateTime? endDateTime;
    if (_endDate != null) {
      if (_endTime != null) {
        endDateTime = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      } else {
        // Si no se especifica _endTime, asumir el final del día seleccionado en _endDate
        endDateTime = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
        );
      }
    }

    // Crear el nuevo evento con los DateTime completos
    Event newEvent = Event(
      name: _name,
      description: _description,
      timeslot: Daily(startDate: startDateTime, endDate: endDateTime, frequency: 1), // Usar startDateTime y endDateTime
      state: EVENT_STATE.Scheduled,
      categoryId: _selectedCategoryId,
    );

    int result = await _eventsDao.addEvent(newEvent);
    if (result > 0) {
      _resetFormFields();
      Navigator.of(context).pop(); // Esto cierra el modal
      _loadEvents(); // Recargar la lista de eventos
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error añadiendo el evento. Por favor, intenta de nuevo.')),
      );
    }
  }


  void _resetFormFields() {
    _formKey.currentState?.reset();
    setState(() {
      _name = '';
      _description = '';
      _startDate = null;
      _startTime = null;
      _endDate = null;
      _endTime = null;
      _selectedCategoryId = null;
    });
  }

}
