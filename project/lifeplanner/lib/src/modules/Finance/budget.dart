import 'dart:convert';
import 'package:lifeplanner/src/modules/Organization/habittracker.dart';

class Budget {
  int? id;
  final Month month;
  double totalExpenseExpected;
  double totalIncomeExpected;
  Map<int, double> budgetExpenses; // budget category id (to pick from budget_categories) - amount expected
  Map<int, double> budgetIncomes;

  Budget({
    this.id,
    required this.month,
    required this.totalExpenseExpected,
    required this.totalIncomeExpected,
    required this.budgetExpenses,
    required this.budgetIncomes,
  });

  Map<String, dynamic> toMap() {
    var map = {
      'month': month.name,  
      'total_expense_expected': totalExpenseExpected,
      'total_income_expected': totalIncomeExpected,
      'budget_expenses': jsonEncode(budgetExpenses.map((key, value) => MapEntry(key.toString(), value))),
      'budget_incomes': jsonEncode(budgetIncomes.map((key, value) => MapEntry(key.toString(), value))),
    };

    if(id != null){
      map['id'] = id!;
    }

    return map;
  
  }

  static Budget fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      month: Month.values.firstWhere((m) => m.toString() == 'Month.${map['month']}'),
      totalExpenseExpected: map['total_expense_expected'].toDouble(),
      totalIncomeExpected: map['total_income_expected'].toDouble(),
      budgetExpenses: Map.from(jsonDecode(map['budget_expenses'])).map((key, value) => MapEntry(int.parse(key), value.toDouble())),
      budgetIncomes: Map.from(jsonDecode(map['budget_incomes'])).map((key, value) => MapEntry(int.parse(key), value.toDouble())),
    );
  }
}
