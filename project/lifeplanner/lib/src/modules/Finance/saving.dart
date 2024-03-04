class Saving {
  final String name;
  final String? description;
  final double targetAmount;
  final Map<DateTime, double> contributions;
  double currentSaved;

  Saving({
    required this.name,
    this.description,
    required this.targetAmount,
    required this.contributions,
    required this.currentSaved,
  });

  void addContribution(DateTime date, double amount) {
    contributions[date] = amount;
    currentSaved += amount;
  }

  @override
  String toString() {
    return 'Saving{name: $name, description: $description, targetAmount: $targetAmount, contributions: $contributions, currentSaved: $currentSaved}';
  }
}

 
