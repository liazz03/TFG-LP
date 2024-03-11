import 'package:lifeplanner/src/modules/Activity/course.dart';

enum LANGUAGE_LEVEL {A1, A2, B1, B2, C1,C2,}

class Language extends Course {
  LANGUAGE_LEVEL level;
  int actual_study_time_x_week = 0;


  Language(String name, String description, bool finished, int dedicationTimePerWeek, int this.actual_study_time_x_week, int targetDuration, this.level)
      : super(name, description, finished, dedicationTimePerWeek, targetDuration, actual_study_time_x_week);
}