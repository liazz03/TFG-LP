enum Month {
  January,
  February,
  March,
  April,
  May,
  June,
  July,
  August,
  September,
  October,
  November,
  December,
}

class Budget {
  final Month month;
  double totalExpenseExpected;
  double totalIncomeExpected;
  Map<String, double> expenses;
  Map<String, double> incomes;
  String budgetCategory;

  Budget({
    required this.month,
    required this.totalExpenseExpected,
    required this.totalIncomeExpected,
    required this.expenses,
    required this.incomes,
    required this.budgetCategory,
  });

  @override
  String toString() {
    return 'Budget{month: $month, totalExpenseExpected: $totalExpenseExpected, totalIncomeExpected: $totalIncomeExpected, expenses: $expenses, incomes: $incomes}';
  }
}



