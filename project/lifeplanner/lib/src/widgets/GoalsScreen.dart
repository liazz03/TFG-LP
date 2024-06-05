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
  final _formKey = GlobalKey<FormState>(); // Form

  // Form data
  String _name = '';
  String? _description;
  DateTime? _targetDate; 

  // goal being edited
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
                    subtitle: Text(_targetDate != null ? DateFormat('yyyy-MM-dd').format(_targetDate!) : 'No date chosen'),
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
  _name = goal.name;
  _description = goal.description;
  _targetDate = goal.targetDate;
  _currentGoal = goal; 

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
                          // Update the goal in db
                          Goal updatedGoal = Goal(
                            id: _currentGoal!.id, // same id
                            name: _name,
                            description: _description,
                            targetDate: _targetDate,
                            actualDate_achievement: _currentGoal!.actualDate_achievement,
                            achieved: _currentGoal!.achieved,
                          );
                          await _goalDao.updateGoal(updatedGoal);
                          Navigator.pop(context); 
                          setState(() {}); 
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
    Navigator.pop(context);
    setState(() {}); // Refresh  list of goals
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM').format(now);
    String currentYear = now.year.toString();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.done_all, size: 32,),
             SizedBox(width: 8), 
            Text('Goals'),
            
          ],
        ),
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
          } else if (!snapshot.hasData) {
            return ListView(
              children: [
                _emptySection('This Week\'s Goals'),
                _emptySection('$currentMonth Goals'),
                _emptySection('$currentYear Goals'),
                _emptySection('Other Goals'),
                _emptySection('Achieved Goals'),
              ],
            );
          } else {
            List<Goal> allGoals = snapshot.data!;
            List<Goal> thisWeeksGoals = allGoals.where((goal) => goal.type == GoalType.weekly && !goal.achieved).toList();
            List<Goal> monthGoals = allGoals.where((goal) => goal.type == GoalType.monthly && !goal.achieved).toList();
            List<Goal> yearGoals = allGoals.where((goal) => goal.type == GoalType.yearly && !goal.achieved).toList();
            List<Goal> otherGoals = allGoals.where((goal) => goal.type == GoalType.noDate && !goal.achieved || goal.targetDate != null && goal.targetDate!.isBefore(now) && !goal.achieved).toList();
            List<Goal> achievedGoals = allGoals.where((goal) => goal.achieved).toList();

            return ListView(
              children: [
                _goalSection('This Week\'s Goals', thisWeeksGoals),
                _goalSection('$currentMonth Goals', monthGoals),
                _goalSection('$currentYear Goals', yearGoals),
                _goalSection('Other Goals', otherGoals),
                _achievedGoalSection('Achieved Goals', achievedGoals),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _achievedGoalSection(String title, List<Goal> goals) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              decoration: BoxDecoration(
                border:  Border(bottom: BorderSide(width: 3.0, color: Theme.of(context).dividerColor)),
              ),
              child: Text(title, style: Theme.of(context).textTheme.headline6),
            ),
            if (goals.isEmpty)
              ListTile(title: Text('No $title')),
            ...goals.map((goal) => _achievedGoalInfoDisp(goal)).toList(),
          ],
        );
  }

  Widget _achievedGoalInfoDisp(Goal goal) {
    String formattedDate = goal.targetDate != null ? DateFormat('yyyy-MM-dd').format(goal.targetDate!) : 'No target date';
    return ListTile(
      title: Text(goal.name),
      subtitle: Text('${goal.description ?? 'No description'}\nTarget Date: $formattedDate'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: () => _showEditGoalSheet(goal),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red[800]),
            onPressed: () => _confirmDeleteGoal(goal.id),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }


  Widget _goalSection(String title, List<Goal> goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          decoration: BoxDecoration(
            border:  Border(bottom: BorderSide(width: 3.0, color: Theme.of(context).dividerColor)),
          ),
          child: Text(title, style: Theme.of(context).textTheme.headline6),
        ),
        if (goals.isEmpty)
          ListTile(title: Text('No $title')),
        ...goals.map((goal) => _goalInfoDisp(goal)).toList(),
      ],
    );
  }

  Widget _emptySection(String title) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 2.0, color: Theme.of(context).dividerColor)),
      ),
      child: Text(title, style: Theme.of(context).textTheme.headline6),
    );
  }

  Widget _goalInfoDisp(Goal goal) {
    String formattedDate = goal.targetDate != null ? DateFormat('yyyy-MM-dd').format(goal.targetDate!) : 'No target date';
    return ListTile(
      title: Text(goal.name),
      subtitle: Text('${goal.description ?? 'No description'}\nTarget Date: $formattedDate'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: () => _showEditGoalSheet(goal),
          ),
          IconButton(
            icon: Icon(Icons.check, color: Colors.green[800]),
            onPressed: () => _markAsAchieved(goal),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red[800]),
            onPressed: () => _confirmDeleteGoal(goal.id),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

   Future<void> _markAsAchieved(Goal goal) async {
    goal.achieved = true;
    await _goalDao.updateGoal(goal);
    setState(() {}); 
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
                Navigator.of(context).pop(); 
                await _goalDao.deleteGoal(id);
                setState(() {}); 
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Goal deleted successfully.")));
              },
            ),
          ],
        );
      },
    );
  }

}
