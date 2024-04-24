import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/Courses_dao.dart';
import 'package:lifeplanner/src/database/dao/Subjects_dao.dart';
import 'package:lifeplanner/src/modules/Activity/course.dart';
import 'package:lifeplanner/src/modules/Activity/grades.dart';
import 'package:lifeplanner/src/modules/Activity/subject.dart';
import 'package:lifeplanner/src/modules/Organization/Schedule_def.dart';
import 'package:schedules/schedules.dart';

class AcademicsScreen extends StatefulWidget {
  @override
  _AcademicsScreenState createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen> {

  // Course
  final _courseFormKey = GlobalKey<FormState>(); 
  String _courseName = '';
  String? _courseDescription;
  int _dedicationStudyTimeXWeek = 0;
  final CourseDao _courseDao = CourseDao(); 
  
  // Subject
  final SubjectDao _subjectDao = SubjectDao(); 
  List<Weekly> _weeklySchedule = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories, size: 32,),
             SizedBox(width: 8), 
            Text('Academics'),
            
          ],
        ),
      ),
      body: ListView(
        children: [
          sectionHeader('Subjects', () => _addNewSubject(context)),
          listSubjects(),
          sectionHeader('Courses', () => _addNewCourse(context)),
          listCourses(),
        ],
      ),
    );
  }

  Widget sectionHeader(String title, VoidCallback onAddPressed) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 3.0, color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headline6),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: onAddPressed,
          )
        ],
      ),
    );
  }

  Widget listSubjects() {
    return FutureBuilder<List<Subject>>(
      future: _subjectDao.getAllSubjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return ListTile(title: Text('Error loading subjects'));
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return ListTile(title: Text('No subjects found!'));
        } else if (snapshot.hasData) {
          return Column(
            children: snapshot.data!.map((subject) => ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16.0),
              title: Row(
                children: [
                  Expanded(child: Text(subject.name)),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    color: Color.fromARGB(255, 40, 140, 198),
                    onPressed: () => print("todo"),
                  ),
                  IconButton(
                    icon: Icon(Icons.account_tree_rounded),
                    color: Color.fromARGB(255, 6, 68, 139),
                    onPressed: () => _showAddGradeSheet(subject),
                  ),
                  IconButton(
                  icon: Icon(Icons.add_chart),
                  color: Colors.blue[800],
                  onPressed: () => _showAddEvaluationSheet(subject),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => print("TODO"),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.red[800],
                    onPressed: () => _confirmDeleteSubject(subject.id),
                  ),
                ],
              ),
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (subject.description != null && subject.description!.isNotEmpty)
                          Text('Description: ${subject.description}'),
                        Text(
                          'Schedule:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(subject.schedule!.asString()), 
                        SizedBox(height: 8),
                        Text(
                          'Time Commitment:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Dedication per week: ${subject.dedication_time_x_week} hours'),
                        Text('Study time this week: ${subject.actual_dedication_time_x_week} hours'),
                        Text('Total dedication time: ${subject.total_dedication_time} hours'),
                        SizedBox(height: 8),
                        if (subject.target_average != null || subject.room != null)
                          Text(
                            'Academic Details:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        if (subject.target_average != null)
                          Text('Target average: ${subject.target_average}'),
                        if (subject.room != null) Text('Room: ${subject.room}'),
                        SizedBox(height: 8),
                        Text(
                          'Performance:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Grades: ${subject.grades.assessments.isEmpty ? "No grades registered yet" : subject.grades.calculate_average()}'),
                        SizedBox(height: 8),
                        Text(
                          'Evaluations:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...subject.evaluations.isEmpty
                            ? [Text("No upcoming evaluations")]
                            : subject.evaluations.map((e) => Text("${e.name} - ${e.evaluation_type.toString().split('.').last} - ${DateFormat('dd/MM/yy').format(e.date)}${e.date.hour != 0 || e.date.minute != 0 ? ' ${DateFormat('HH:mm').format(e.date)}' : ''}")),
                        SizedBox(height: 16), 
                      ],
                    ),
                  ),
                ),
              ],
            )).toList(),
          );
        }
        return SizedBox();
      },
    );
  }


Future<void> _showAddGradeSheet(Subject subject) async {
  final _gradeFormKey = GlobalKey<FormState>();
  final _gradeNameController = TextEditingController();
  final _gradeWeightController = TextEditingController();
  final _gradeScoreController = TextEditingController();
  String? selectedAssessmentName;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _gradeFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Add Grade or Assessment', style: Theme.of(context).textTheme.headline6),
                DropdownButtonFormField<String>(
                  value: selectedAssessmentName,
                  hint: Text("Select Assessment"),
                  onChanged: (String? newValue) {
                    selectedAssessmentName = newValue;
                  },
                  items: subject.grades.assessments.map<DropdownMenuItem<String>>((Assessment assessment) {
                    return DropdownMenuItem<String>(
                      value: assessment.name,
                      child: Text(assessment.name),
                    );
                  }).toList(),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the bottom sheet to show the dialog
                    _showAddAssessmentDialog(subject);
                  },
                  child: Text('Add Assessment'),
                ),
                TextFormField(
                  controller: _gradeNameController,
                  decoration: InputDecoration(labelText: 'Grade Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a grade name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _gradeWeightController,
                  decoration: InputDecoration(labelText: 'Grade Weight'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _gradeScoreController,
                  decoration: InputDecoration(labelText: 'Grade Score'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Please enter a valid score';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_gradeFormKey.currentState!.validate()) {
                      _gradeFormKey.currentState!.save();
                      if (selectedAssessmentName == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select or add an assessment.")));
                        return;
                      }
                      // Find the selected assessment
                      Assessment selectedAssessment = subject.grades.assessments.firstWhere(
                        (assessment) => assessment.name == selectedAssessmentName,
                        orElse: () {
                          // If no assessment was selected, create a new one
                          final newAssessment = Assessment(
                            _gradeNameController.text,
                            int.parse(_gradeWeightController.text.isEmpty ? '0' : _gradeWeightController.text),
                            [],
                          );
                          subject.grades.assessments.add(newAssessment);
                          return newAssessment;
                        },
                      );
                      // Add the new grade to the selected assessment
                      selectedAssessment.grades.add(
                        Grade(
                          _gradeNameController.text,
                          int.parse(_gradeWeightController.text.isEmpty ? '0' : _gradeWeightController.text),
                          double.parse(_gradeScoreController.text),
                        ),
                      );

                      // Update the subject with the new assessments list
                      _subjectDao.updateSubject(subject).then((result) {
                        if (result > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grade added successfully")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add grade")));
                        }
                        setState(() {});
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    }
                  },
                  child: Text('Add Grade'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  Future<void> _showAddAssessmentDialog(Subject subject) async {
    String assessmentName = '';
    int assessmentWeight = 0;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Assessment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  assessmentName = value;
                },
                decoration: InputDecoration(hintText: "Assessment Name"),
              ),
              TextField(
                onChanged: (value) {
                  assessmentWeight = int.tryParse(value) ?? 0;
                },
                decoration: InputDecoration(hintText: "Weight"),
                keyboardType: TextInputType.number,
              ),
            ],
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
              onPressed: () {
                if (assessmentName.isNotEmpty) {
                  Assessment newAssessment = Assessment(
                    assessmentName,
                    assessmentWeight,
                    [],
                  );
                  subject.grades.assessments.add(newAssessment);
                  _subjectDao.updateSubject(subject).then((result) {
                    Navigator.of(context).pop(); 
                    if (result > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Assessment added successfully")));
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add assessment")));
                    }
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }


  void _showAddEvaluationSheet(Subject subject) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _nameController = TextEditingController();
    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;
    Evaluation_type? _selectedType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Add New Evaluation', style: Theme.of(context).textTheme.headline6),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Evaluation Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an evaluation name';
                      }
                      return null;
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text(_selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) {
                        _selectedDate = date;
                        setState(() {});
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text(_selectedTime == null ? 'Select Time' : _selectedTime!.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        _selectedTime = time;
                        setState(() {});
                      }
                    },
                  ),
                  DropdownButtonFormField<Evaluation_type>(
                    value: _selectedType,
                    onChanged: (value) {
                      _selectedType = value;
                      setState(() {});
                    },
                    items: Evaluation_type.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Evaluation Type'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null && _selectedType != null) {
                        _formKey.currentState!.save();
                        final DateTime fullDateTime = DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime!.hour,
                          _selectedTime!.minute,
                        );
                        Evaluation newEvaluation = Evaluation(
                          name: _nameController.text,
                          date: fullDateTime,
                          evaluation_type: _selectedType!,
                        );
                        subject.evaluations.add(newEvaluation);
                        _subjectDao.updateSubject(subject);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Add Evaluation'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {});  
    });
  }


  void _confirmDeleteSubject(int? subjectId) {
    if (subjectId == null) {
      print("Subject ID is null.");
      return; 
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Subject'),
          content: Text('Are you sure you want to delete this subject?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _subjectDao.deleteSubject(subjectId);
                Navigator.of(context).pop();
                setState(() {
                  print("Subject deleted successfully.");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Subject deleted successfully.")));
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewSubject(BuildContext context) {
    final _subjectFormKey = GlobalKey<FormState>();  // Form key 
    TextEditingController _nameController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    TextEditingController _dedicationController = TextEditingController();
    TextEditingController _targetAverageController = TextEditingController();
    TextEditingController _roomController = TextEditingController();

    List<Assessment> _assesments = [];
    List<Evaluation> __evaluations = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _subjectFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Add New Subject', style: Theme.of(context).textTheme.headline6),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Subject Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a subject name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description (Optional)'),
                  ),
                  // Placeholder for schedule addition logic
                  ElevatedButton(
                    onPressed: _addTimeSlot,
                    child: Text('Add Schedule Slot'),
                  ),
                  ..._weeklySchedule.map((weekly) {
                    return Column(
                      children: [
                        Text('${DateFormat('EEEE').format(weekly.startDate)} - ${DateFormat('jm').format(weekly.startDate)} to ${DateFormat('jm').format(weekly.endDate!)}'),
                      ],
                    );
                  }).toList(),
                  TextFormField(
                    controller: _dedicationController,
                    decoration: InputDecoration(labelText: 'Dedication time per week (in hours)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _targetAverageController,
                    decoration: InputDecoration(labelText: 'Target Average (Optional)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _roomController,
                    decoration: InputDecoration(labelText: 'Room Number (Optional)'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_subjectFormKey.currentState!.validate()) {
                        _subjectFormKey.currentState!.save();

                        Schedule_def _schedule = Schedule_def(schedule: _weeklySchedule);

                        // Create new subject
                        Subject newSubject = Subject(
                          id: null,
                          name: _nameController.text,
                          description: _descriptionController.text,
                          schedule: _schedule,
                          dedication_time_x_week: int.parse(_dedicationController.text),
                          actual_dedication_time_x_week: 0, 
                          total_dedication_time: 0,  
                          target_average: _targetAverageController.text.isEmpty ? 0 : double.parse(_targetAverageController.text),
                          room: int.tryParse(_roomController.text),
                          grades: Grades(_assesments),
                          evaluations: __evaluations
                        );
                        // save to db
                        _saveSubject(newSubject);                    
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save Subject'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _weeklySchedule.clear();
    });
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

  void _saveSubject(Subject subject) async {
    int result = await _subjectDao.addSubject(subject);
    if (result != 0) {
      subject.id = result;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Subject added successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add subject")));
    }
    setState(() {});
  }


  Widget listCourses() {
    return FutureBuilder<List<Course>>(
      future: _courseDao.getAllCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return ListTile(title: Text('Error loading courses'));
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return ListTile(title: Text('No courses found!'));
        } else if (snapshot.hasData) {
          return Column(
            children: snapshot.data!.map((course) => ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16.0),
              title: Row(
                children: [
                  Expanded(child: Text(course.name)),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    color: Color.fromARGB(255, 40, 140, 198),
                    onPressed: () => print("todo"),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showEditCourseSheet(course),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.red[800],
                    onPressed: () => _confirmDeleteCourse(course.id),
                  ),
                ],
              ),
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (course.description != null && course.description!.isNotEmpty)
                          Text('Description: ${course.description}'),
                        SizedBox(height: 8),
                        Text(
                          'Commitment:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Dedication per week: ${course.dedication_study_time_x_week} hours'),
                        Text('Study time this week: ${course.actual_study_time_x_week} hours'),
                        Text('Total dedication time: ${course.total_dedication_time} hours'),
                        SizedBox(height: 8),
                        Text(
                          'Status:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Finished: ${course.finished ? "Yes" : "No"}'),
                        SizedBox(height: 16), // Adds space after the status section
                      ],
                    ),
                  ),
                ),
              ],
            )).toList(),
          );
        }
        return SizedBox(); 
      },
    );
  }

  void _showEditCourseSheet(Course course) {
    TextEditingController _nameController = TextEditingController(text: course.name);
    TextEditingController _descriptionController = TextEditingController(text: course.description);
    TextEditingController _dedicationController = TextEditingController(text: course.dedication_study_time_x_week.toString());
    bool _isFinished = course.finished;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Edit Course', style: Theme.of(context).textTheme.headline6),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Course Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a course name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description (Optional)'),
                  ),
                  TextFormField(
                    controller: _dedicationController,
                    decoration: InputDecoration(labelText: 'Target Study Time per Week (Hours)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter study time per week';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  SwitchListTile(
                  title: Text('Mark as completed'),
                  value: _isFinished,
                  onChanged: (bool value) {
                    setState(() {
                      _isFinished = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateCourse(
                      course.id,
                      _nameController.text,
                      _descriptionController.text,
                      int.tryParse(_dedicationController.text) ?? course.dedication_study_time_x_week,
                      _isFinished, 
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Update Course'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void _updateCourse(int? courseId, String newName, String? newDescription, int newDedicationTimePerWeek, bool isFinished) async {
    if (courseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: No course ID provided for update.")));
      return;
    }

    final currentCourse = await _courseDao.getCourseById(courseId);
    if (currentCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Course not found.")));
      return;
    }

    Course updatedCourse = Course(
      newName,
      newDescription,
       courseId,
      isFinished, 
      newDedicationTimePerWeek,
      currentCourse.actual_study_time_x_week,
      currentCourse.total_dedication_time,
    );

    int result = await _courseDao.updateCourse(updatedCourse);
    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Course updated successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update course")));
    }

    setState(() {});
  }

  void _confirmDeleteCourse(int? courseId) {
    if (courseId == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Course'),
          content: Text('Are you sure you want to delete this course?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _courseDao.deleteCourse(courseId);
                Navigator.of(context).pop(); 
                setState(() {}); 
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Course deleted successfully.")));
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewCourse(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _courseFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Add New Course', style: Theme.of(context).textTheme.headline6),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Course Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a course name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _courseName = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description (Optional)'),
                    onSaved: (value) {
                      _courseDescription = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Study Time per Week (Hours)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter study time per week';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _dedicationStudyTimeXWeek = int.parse(value!);
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_courseFormKey.currentState!.validate()) {
                        _courseFormKey.currentState!.save();
                        Course newCourse = Course(
                          _courseName, _courseDescription, null, 
                          false, _dedicationStudyTimeXWeek, 0, 0
                        );
                        _saveCourse(newCourse);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save Course'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveCourse(Course course) async {
    int result = await _courseDao.addCourse(course);
    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Course added successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add course")));
    }
    setState(() {});
  }


}
