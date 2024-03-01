import 'package:lifeplanner/src/activity/course.dart';

enum LANGUAGE_LEVEL {
  A1,
  A2,
  B1,
  B2,
  C1,
  C2,
}

class Language extends Course {
  LANGUAGE_LEVEL level;

  Language(String name, String description, bool finished, int dedicationTimePerWeek, int targetDuration, this.level)
      : super(name, description, finished, dedicationTimePerWeek, targetDuration);
}