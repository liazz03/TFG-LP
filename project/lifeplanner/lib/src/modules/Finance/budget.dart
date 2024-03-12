import 'package:lifeplanner/src/modules/Organization/habittracker.dart';

class Budget {
  final Month month;
  double totalExpenseExpected;
  double totalIncomeExpected;
  Map<String, double> expenses;
  Map<String, double> incomes;

  Budget({
    required this.month,
    required this.totalExpenseExpected,
    required this.totalIncomeExpected,
    required this.expenses,
    required this.incomes,
  });

  @override
  String toString() {
    return 'Budget{month: $month, totalExpenseExpected: $totalExpenseExpected, totalIncomeExpected: $totalIncomeExpected, expenses: $expenses, incomes: $incomes}';
  }
}



