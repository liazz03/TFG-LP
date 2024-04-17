import 'package:lifeplanner/src/modules/Organization/sprint.dart';
import 'package:schedules/schedules.dart';

enum PROJECT_STATE { IN_PROGRESS, DONE, CANCELLED, PLANNED }

class Project {
  String name;
  String description;
  Schedule expectedDuration;
  PROJECT_STATE state;
  double percentageComplete;
  List<Sprint>? sprints; 

  Project({
    required this.name,
    required this.description,
    required this.expectedDuration,
    required this.state,
    this.percentageComplete = 0,
    this.sprints,
  });

  void add_sprint(Sprint sprint){
    this.sprints?.add(sprint);
  }

  @override
  String toString() {
    return 'Project{name: $name, description: $description, expectedDuration: $expectedDuration, state: $state, percentageComplete: $percentageComplete, sprints: $sprints}';
  }
}
