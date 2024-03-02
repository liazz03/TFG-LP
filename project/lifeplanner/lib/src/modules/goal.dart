enum GoalType { weekly, monthly, yearly, noDate }

class Goal {
  String name;
  String? description;
  DateTime? _targetDate;
  GoalType? type;
  DateTime? actualDate;
  bool achieved;

  Goal({
    required this.name,
    this.description,
    DateTime? targetDate,
    this.actualDate,
    this.achieved = false,
  }) {
    _targetDate = targetDate;
    _updateType(this);
  }

  void _updateType(Goal goal) {
    if (goal._targetDate == null) {
      goal.type = GoalType.noDate;
      return;
    }

    DateTime now = DateTime.now();
    if (goal._targetDate!.isBefore(now.add(Duration(days: 7)))) {
      goal.type = GoalType.weekly;
    } else if (goal._targetDate!.month == now.month && goal._targetDate!.year == now.year) {
      goal.type = GoalType.monthly;
    } else {
      goal.type = GoalType.yearly;
    }
  }

  // upon change in the targetDate update the type
  set targetDate(DateTime? newTargetDate) {
    _targetDate = newTargetDate;
    _updateType(this);
  }
}
