import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/Goal_dao.dart';
import 'package:lifeplanner/src/modules/Organization/goal.dart';

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalDao _goalDao = GoalDao();
  final _formKey = GlobalKey<FormState>(); // Form key

  // Form data
  String _name = '';
  String? _description;
  DateTime? _targetDate; // Variable to hold the target date

  // Current goal being edited
  Goal? _currentGoal;


  void _showAddGoalSheet() {
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
                  Text('Create New Goal', style: Theme.of(context).textTheme.headline6),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Goal Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a goal name';
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
                  SizedBox(height: 20),
                  ListTile(
                    title: Text('Select Target Date'),
                    subtitle: Text(_targetDate != null ? _targetDate.toString() : 'No date chosen'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _pickDate(context),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _saveGoal();
                      }
                    },
                    child: Text('Save Goal'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditGoalSheet(Goal goal) {
  // Pre-fill the form with the current goal's data
  _name = goal.name;
  _description = goal.description;
  _targetDate = goal.targetDate;
  _currentGoal = goal; // Keep track of the current goal being edited

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Edit Goal', style: Theme.of(context).textTheme.headline6),
                    TextFormField(
                      initialValue: _name,
                      decoration: InputDecoration(labelText: 'Goal Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a goal name';
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
                    SizedBox(height: 20),
                    ListTile(
                      title: Text('Select Target Date'),
                      subtitle: Text(_targetDate != null
                          ? DateFormat('yyyy-MM-dd').format(_targetDate!)
                          : 'No date chosen'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _pickDate(context),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // Update the goal in the database
                          Goal updatedGoal = Goal(
                            id: _currentGoal!.id, // Keep the same ID
                            name: _name,
                            description: _description,
                            targetDate: _targetDate,
                            actualDate_achievement: _currentGoal!.actualDate_achievement,
                            achieved: _currentGoal!.achieved,
                          );
                          await _goalDao.updateGoal(updatedGoal);
                          Navigator.pop(context); // Close the modal bottom sheet
                          setState(() {}); // Refresh the list of goals
                        }
                      },
                      child: Text('Update Goal'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}


  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _saveGoal() async {
    if (_targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a target date for the goal.")));
      return;
    }
    Goal newGoal = Goal(
      name: _name,
      description: _description,
      targetDate: _targetDate,
      actualDate_achievement: null,
      achieved: false,
    );
    await _goalDao.addGoal(newGoal);
    Navigator.pop(context); // Close the modal bottom sheet
    setState(() {}); // Refresh the list of goals
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goals'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            iconSize: 30,
            onPressed: _showAddGoalSheet,
          ),
        ],
      ),
      body: FutureBuilder<List<Goal>>(
        future: _goalDao.getAllGoals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No goals found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final goal = snapshot.data![index];
                String formattedDate = goal.targetDate != null ? 
                  DateFormat('yyyy-MM-dd').format(goal.targetDate!) : 
                  'No target date';
                return ListTile(
                  title: Text(goal.name),
                  subtitle: Text('${goal.description ?? 'No description'}\nTarget Date: $formattedDate'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: const Color.fromARGB(255, 0, 0, 0)),
                        onPressed: () => _showEditGoalSheet(goal),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Color.fromARGB(255, 163, 21, 10)),
                        onPressed: () => _confirmDeleteGoal(goal.id),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteGoal(int? id) {
    if (id == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Goal'),
          content: Text('Are you sure you want to delete this goal?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                await _goalDao.deleteGoal(id);
                setState(() {}); // Refresh the list of goals after deletion
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Goal deleted successfully.")));
              },
            ),
          ],
        );
      },
    );
  }

}
