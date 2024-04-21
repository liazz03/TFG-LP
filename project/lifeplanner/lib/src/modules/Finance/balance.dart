class Balance {
  int? id;
  double currentAvailable;
  double expectedRemaining;

  Balance({
    id,
    required this.currentAvailable,
    required this.expectedRemaining,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 0, // only one row
      'current_available': currentAvailable,
      'expected_remaining': expectedRemaining,
    };
  }

  static Balance fromMap(Map<String, dynamic> map) {
    return Balance(
      id: map['id'],
      currentAvailable: map['current_available'],
      expectedRemaining: map['expected_remaining'],
    );
  }

}
