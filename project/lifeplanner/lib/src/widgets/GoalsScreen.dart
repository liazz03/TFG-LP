import 'package:flutter/material.dart';
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

  void _showAddGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.8, // Adjust the height as needed
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

  void _saveGoal() async {
    Goal newGoal = Goal(
      name: _name,
      description: _description,
      targetDate: DateTime.now(), // Example placeholder
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
                return ListTile(
                  title: Text(goal.name),
                  subtitle: goal.description != null ? Text(goal.description!) : null,
                  // Add more UI elements or functionalities as needed
                );
              },
            );
          }
        },
      ),
    );
  }
}
