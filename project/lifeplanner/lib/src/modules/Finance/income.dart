class Income {
  DateTime date;
  double amount;
  String concept;
  bool budget_or_not;
  String budgetCategory;

  Income({required this.date, required this.amount, required this.concept, required this.budget_or_not, required this.budgetCategory});

  @override
  String toString() {
    return 'Income{date: $date, amount: $amount, concept: $concept}';
  }
}
