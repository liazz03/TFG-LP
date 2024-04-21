import 'dart:convert';

class Saving {
  int? id;
  String name;
  String? description;
  double targetAmount;
  double currentSaved;
  Map<DateTime, double> contributions;

  Saving({
    this.id,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.currentSaved,
    required this.contributions,
  });

  void addContribution(DateTime date, double amount) {
    contributions.update(
      date,
      (existing) => existing + amount, 
      ifAbsent: () => amount, 
    );

    currentSaved += amount;
  }

  @override
  String toString() {
    return 'Saving{id: $id, name: $name, description: $description, targetAmount: $targetAmount, currentSaved: $currentSaved, contributions: $contributions}';
  }

  Map<String, dynamic> toMap() {
    var map = {
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_saved': currentSaved,
      'contributions': json.encode(contributions.map((key, value) => MapEntry(key.toIso8601String(), value))),
    };

    if(id != null){
      map['id'] = id;
    }

    return map;
  }

  static Saving fromMap(Map<String, dynamic> map) {
    var contributionsJson = json.decode(map['contributions']) as Map<String, dynamic>;
    Map<DateTime, double> contributions = contributionsJson.map((key, value) => MapEntry(DateTime.parse(key), value as double));

    return Saving(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      targetAmount: map['target_amount'],
      currentSaved: map['current_saved'],
      contributions: contributions,
    );
  }
}
