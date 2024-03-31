import 'package:lifeplanner/src/modules/Activity/activity.dart';
import 'package:lifeplanner/src/modules/Activity/grades.dart';
import 'package:lifeplanner/src/modules/Organization/Schedule_def.dart';

enum Evaluation_type { EXAM, ASSIGNMENT }

class Subject extends Activity
{
  Schedule_def schedule;
  int dedication_study_time_x_week;
  double target_average;
  int room;
  Grades grades;
  List<Evaluation> evaluations;


  Subject(name, description, this.schedule, this.dedication_study_time_x_week, this.target_average, 
  this.room, this.grades, this.evaluations): super(name, description);
}

class Evaluation
{
  String name;
  DateTime date;
  Evaluation_type evaluation_type;

  Evaluation({
    required this.name,
    required this.date,
    required this.evaluation_type,
  });

}