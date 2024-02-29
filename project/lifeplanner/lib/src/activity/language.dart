import 'package:lifeplanner/src/activity/course.dart';

enum Level {
  A1,
  A2,
  B1,
  B2,
  C1,
  C2,
}

class Language extends Course {
  Level level;

  Language(String name, String description, bool finished, int dedicationTimePerWeek, int targetDuration, Level level)
      : super(name, description, finished, dedicationTimePerWeek, targetDuration) {
    this.level = level;
  }
}