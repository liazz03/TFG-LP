enum GoalType { weekly, monthly, yearly, noDate }

class Goal {
  String name;
  String? description;
  DateTime? _targetDate;
  GoalType? type;
  DateTime? actualDate_achievement;
  bool achieved;
  int? id;

  Goal({
    required this.name,
    this.description,
    DateTime? targetDate,
    this.actualDate_achievement,
    this.achieved = false,
    this.id,
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

  DateTime? get targetDate{
    return this._targetDate;
  }

  // object -> sql
  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'description': description,
      'target_date': _targetDate?.toIso8601String(),
      'actual_date_achievement': actualDate_achievement?.toIso8601String(),
      'type': type?.toString(),
      'achieved': achieved ? 1 : 0,
    };

    if (id != null) {  // if goal is new it wont have an id yet
      map['id'] = id;  // if it is an update it will have an id
    }

    return map;
  }

  // sql -> object
  static Goal fromMap(Map<String, dynamic> map) {

    DateTime? act_dat_ach;
    if (map['actual_date_achievement'] != null){
      act_dat_ach = DateTime.tryParse(map['actual_date_achievement']);
    } 

    return Goal(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      targetDate: DateTime.tryParse(map['target_date']),
      actualDate_achievement: act_dat_ach,
      achieved: map['achieved'] == 1,
    );
  }

}

