import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/Balances_dao.dart';
import 'package:lifeplanner/src/database/dao/Budgets_dao.dart';
import 'package:lifeplanner/src/database/dao/Expenses_dao.dart';
import 'package:lifeplanner/src/modules/Finance/balance.dart';
import 'package:lifeplanner/src/modules/Finance/expense.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';


class FinanceScreen extends StatefulWidget {
  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final BalanceDao _balanceDao = BalanceDao();
  final ExpensesDao _expensesDao = ExpensesDao();
  final BudgetDao _budgetDao = BudgetDao();
  List<Map<String, dynamic>> _categories = [];

  double? _currentAvailable;
  double? _expectedRemaining;

  Map<int, List<Expense>> monthlyExpensesMap = {};

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _loadCategories();
    _fetchExpensesForYear(DateTime.now().year);
  }

  Future<void> _fetchExpensesForYear(int year) async {
    List<Expense> yearlyExpenses = await _expensesDao.getExpensesByYear(year);
    setState(() {
      // expenses by month
      monthlyExpensesMap = {};
      for (var expense in yearlyExpenses) {
        int month = expense.date.month;
        monthlyExpensesMap.putIfAbsent(month, () => []).add(expense);
      }
    });
  }

  Future<void> _loadCategories() async {
    var categories = await _budgetDao.getAllBudgetCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _loadBalance() async {
    Balance? balance = await _balanceDao.getBalance();
    if (balance == null) {
      _requestInitialBalance();
    } else {
      setState(() {
        _currentAvailable = balance.currentAvailable;
        _expectedRemaining = balance.expectedRemaining;
      });
    }
  }

  Future<void> _requestInitialBalance() async {
    TextEditingController _balanceController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your current Balance'),
          content: TextField(
            controller: _balanceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: "Current Available Money"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                double? initialBalance = double.tryParse(_balanceController.text);
                if (initialBalance != null) {
                  _createInitialBalance(initialBalance);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createInitialBalance(double initialBalance) async {
    Balance newBalance = Balance(
      currentAvailable: initialBalance,
      expectedRemaining: initialBalance,
    );
    await _balanceDao.setBalance(newBalance);
    setState(() {
      _currentAvailable = initialBalance;
      _expectedRemaining = initialBalance;
    });
  }

  void _showAddExpenseSheet() {
    final _formKey = GlobalKey<FormState>();
    final _dateController = TextEditingController();
    final _amountController = TextEditingController();
    final _conceptController = TextEditingController();
    bool _budgetOrNot = false;
    int? _selectedCategoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ).then((pickedDate) {
                        if (pickedDate != null) {
                          _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter date';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _conceptController,
                    decoration: InputDecoration(labelText: 'Concept'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a concept';
                      }
                      return null;
                    },
                  ),
                  SwitchListTile(
                    title: Text("Is it a budgeted expense?"),
                    value: _budgetOrNot,
                    onChanged: (bool value) {
                      setState(() {
                        _budgetOrNot = value;
                      });
                    },
                  ),
                  if (_budgetOrNot)
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      hint: Text("Select Category"),
                      onChanged: (int? newValue) {
                        _selectedCategoryId = newValue;
                      },
                      items: _categories.map<DropdownMenuItem<int>>((category) {
                        return DropdownMenuItem<int>(
                          value: category['id'],
                          child: Text(category['category']),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        DateTime date = DateFormat('yyyy-MM-dd').parse(_dateController.text);
                        double amount = double.parse(_amountController.text);
                        Expense newExpense = Expense(
                          date: date,
                          amount: amount,
                          concept: _conceptController.text,
                          budget_or_not: _budgetOrNot,
                          categoryId: _selectedCategoryId, 
                        );
                        _expensesDao.addExpense(newExpense);

                        // Update the current available balance
                        var currentBalance = await _balanceDao.getBalance();
                        if (currentBalance != null) {
                          currentBalance.currentAvailable -= amount;
                          await _balanceDao.setBalance(currentBalance);
                          _loadBalance();
                        }
                        Navigator.pop(context);
                        setState(() {});
                      }
                    },
                    child: Text('Add Expense'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finances'),
      ),
      body: SingleChildScrollView( // Wrap the main column in a SingleChildScrollView
        child: Column(
          children: [
            _buildFinanceOverview(),
            Divider(height: 2, thickness: 2),
            ListTile(
              title: Text('Expenses', style: Theme.of(context).textTheme.headline6),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: _showAddExpenseSheet,
              ),
            ),
            _buildExpensesSection(),
            ExpenseBarChart(monthlyExpenses: _calculateMonthlyTotals()),
          ],
        ),
      ),
    );
  }

  List<double> _calculateMonthlyTotals() {
    return List.generate(12, (index) {
      return monthlyExpensesMap[index + 1]?.fold(0.0, (prev, expense) => prev! + expense.amount) ?? 0.0;
    });
  }


  Widget _buildExpensesSection() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return FutureBuilder<List<Expense>>(
      future: _expensesDao.getAllExpenses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading expenses'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return ListTile(title: Text('No expenses recorded'));
        } else {
          var thisMonthExpenses = snapshot.data!
              .where((expense) => expense.date.isAfter(startOfMonth) || expense.date.isAtSameMomentAs(startOfMonth))
              .toList();

          if (thisMonthExpenses.isEmpty) {
            return ListTile(title: Text('No expenses this month'));
          }

          return ExpansionTile(
            title: Text("View this month's expenses"),
            initiallyExpanded: false,
            children: thisMonthExpenses.map((expense) => ListTile(
              leading: Icon(Icons.money_off),
              title: Text('${expense.concept} - \$${expense.amount.toStringAsFixed(2)}'),
              subtitle: Text('Date: ${DateFormat('yyyy-MM-dd').format(expense.date)}'),
            )).toList(),
          );
        }
      },
    );
  }

  Widget _buildFinanceOverview() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('Current Available:', style: TextStyle(fontSize: 18)),
          subtitle: Text('\$${_currentAvailable?.toStringAsFixed(2)}', style: TextStyle(fontSize: 24)),
        ),
        ListTile(
          title: Text('Expected Remaining:', style: TextStyle(fontSize: 18)),
          subtitle: Text('\$${_expectedRemaining?.toStringAsFixed(2)}', style: TextStyle(fontSize: 24)),
        ),
      ],
    );
  }
}


class ExpenseBarChart extends StatelessWidget {
  final List<double> monthlyExpenses;

  ExpenseBarChart({Key? key, required this.monthlyExpenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Expense summary',
            style:  TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
        AspectRatio(
          aspectRatio: 2,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: monthlyExpenses.reduce(max),
              barTouchData: BarTouchData(
                enabled: true,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (context, value) => const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  rotateAngle: 45,
                  margin: 16,
                  getTitles: (double value) {
                    switch (value.toInt()) {
                      case 0: return 'Jan';
                      case 1: return 'Feb';
                      case 2: return 'Mar';
                      case 3: return 'Apr';
                      case 4: return 'May';
                      case 5: return 'Jun';
                      case 6: return 'Jul';
                      case 7: return 'Aug';
                      case 8: return 'Sep';
                      case 9: return 'Oct';
                      case 10: return 'Nov';
                      case 11: return 'Dec';
                      default: return '';
                    }
                  },
                ),
                topTitles: SideTitles(showTitles: false),
                leftTitles: SideTitles(showTitles: false),
                rightTitles: SideTitles(showTitles: false),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: monthlyExpenses.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(y: entry.value, colors: [Colors.blue, Colors.lightBlueAccent], width: 20)
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

