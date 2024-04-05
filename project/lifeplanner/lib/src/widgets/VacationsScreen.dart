import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/Vacations_dao.dart';
import '../modules/Job/vacation.dart';

class VacationsScreen extends StatefulWidget {
  @override
  _VacationsScreenState createState() => _VacationsScreenState();
}

class _VacationsScreenState extends State<VacationsScreen> {
  final VacationsDao _vacationsDao = VacationsDao();
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String _title = '';
  VacationType _type = VacationType.FREE_DAY;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vacations'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            iconSize: 30,
            onPressed: _showAddVacationSheet,
          ),
        ],
      ),
      body: FutureBuilder<List<Vacation>>(
        future: _vacationsDao.getAllVacations(), // Fetch vacations from the database
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Vacation> vacations = snapshot.data!;
            return ListView.builder(
              itemCount: vacations.length,
              itemBuilder: (context, index) {
                final vacation = vacations[index];
                // Formatting dates
                String formattedStartDate = DateFormat('yyyy-MM-dd').format(vacation.start_date);
                String formattedEndDate = vacation.end_date != null ? DateFormat('yyyy-MM-dd').format(vacation.end_date) : '';
                // Adjusting display based on type
                String dateDisplay = vacation.type == VacationType.FREE_DAY ? formattedStartDate : "$formattedStartDate - $formattedEndDate";
                return ListTile(
                  title: Text(vacation.title),
                  subtitle: Text("$dateDisplay | ${vacation.days} days\n${vacation.type.toString().split('.').last}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Add action to edit this vacation
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Color.fromARGB(255, 163, 21, 10)),
                        onPressed: () => _confirmDeleteVacation(vacation.id),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            );
          } else {
            return Center(child: Text("No vacations found!"));
          }
        },
      ),
    );
  }

  void _confirmDeleteVacation(int? id) {
    if (id == null) return; // Safety check

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Vacation'),
          content: Text('Are you sure you want to delete this vacation?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _vacationsDao.deleteVacation(id);
                Navigator.of(context).pop(); // Close the dialog
                setState(() {}); // Trigger a state change to refresh the list
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vacation deleted successfully.")));
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddVacationSheet() {
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
                  Text('Add New Vacation', style: Theme.of(context).textTheme.headline6),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _title = value!;
                    },
                  ),
                  ListTile(
                    title: Text('Select Start Date'),
                    subtitle: Text(_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'No date chosen'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _pickStartDate(context),
                  ),
                  if (_type != VacationType.FREE_DAY) // Show this only if VacationType is not FREE_DAY
                    ListTile(
                      title: Text('Select End Date'),
                      subtitle: Text(_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'No date chosen'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _pickEndDate(context),
                    ),
                  DropdownButtonFormField<VacationType>(
                    value: _type,
                    onChanged: (VacationType? newValue) {
                      setState(() {
                        _type = newValue!;
                        if (_type == VacationType.FREE_DAY) {
                          _endDate = _startDate; // Set end date same as start date for FREE_DAY
                        }
                      });
                    },
                    items: VacationType.values.map<DropdownMenuItem<VacationType>>((VacationType value) {
                      return DropdownMenuItem<VacationType>(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _addVacation();
                      }
                    },
                    child: Text('Save Vacation'),
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
        if (_type == VacationType.FREE_DAY) {
          _endDate = _startDate; // For FREE_DAY, end date is the same as start date
        }
      });
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
              _endDate = pickedDate;
            });
          }
        }

        void _addVacation() {
          if (_startDate == null || (_type != VacationType.FREE_DAY && _endDate == null)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all the fields')));
            return;
          }

          // Calculate days difference
          int days = _endDate!.difference(_startDate!).inDays + 1; // Add one to include the start date

          // Create the new vacation object
          Vacation newVacation = Vacation(
            start_date: _startDate!,
            end_date: _type == VacationType.FREE_DAY ? _startDate! : _endDate!,
            days: days,
            title: _title,
            type: _type,
          );

          // Save it to the database
          _vacationsDao.addVacation(newVacation).then((id) {
            if (id > 0) {
              Navigator.of(context).pop(); // Close the bottom sheet
              setState(() {}); // Trigger a rebuild, which will refresh the list
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vacation added successfully")));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add vacation")));
            }
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error")));
          });
        }
}
