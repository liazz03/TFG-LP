import 'package:lifeplanner/src/modules/Finance/budget.dart';
import 'package:lifeplanner/src/modules/Finance/expense.dart';
import 'package:lifeplanner/src/modules/Finance/income.dart';
import 'package:lifeplanner/src/modules/Finance/saving.dart';

class Finance {
  double currentAvailable;
  Budget budget;
  List<Expense> expenses;
  List<Income> incomes;
  List<Saving> savings;
  double expectedRemaining;

  Finance({
    required this.currentAvailable,
    required this.budget,
    this.expenses = const [],
    this.incomes = const [],
    this.savings = const [],
    required this.expectedRemaining,
  });

  void addExpense(Expense expense) {
    expenses.add(expense);
    currentAvailable -= expense.amount;
  }

  void addIncome(Income income) {
    incomes.add(income);
    currentAvailable += income.amount;
  }

  void addSaving(Saving saving) {
    savings.add(saving);
    currentAvailable -= saving.currentSaved;
  }

  @override
  String toString() {
    return 'Finance{currentAvailable: $currentAvailable, budget: $budget, expenses: $expenses, incomes: $incomes, savings: $savings, expectedRemaining: $expectedRemaining}';
  }
}
