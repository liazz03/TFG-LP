import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeplanner/src/database/dao/Balances_dao.dart';
import 'package:lifeplanner/src/database/dao/Budgets_dao.dart';
import 'package:lifeplanner/src/database/dao/Expenses_dao.dart';
import 'package:lifeplanner/src/database/dao/Incomes_dao.dart';
import 'package:lifeplanner/src/database/dao/Savings_dao.dart';
import 'package:lifeplanner/src/modules/Finance/balance.dart';
import 'package:lifeplanner/src/modules/Finance/budget.dart';
import 'package:lifeplanner/src/modules/Finance/expense.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:lifeplanner/src/modules/Finance/income.dart';
import 'package:lifeplanner/src/modules/Finance/saving.dart';


class FinanceScreen extends StatefulWidget {
  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final BalanceDao _balanceDao = BalanceDao();
  final ExpensesDao _expensesDao = ExpensesDao();
  final BudgetDao _budgetDao = BudgetDao();
  final IncomesDao _incomesDao = IncomesDao();
  final SavingsDao _savingsDao = SavingsDao();

  List<Map<String, dynamic>> _categories = [];

  double? _currentAvailable;
  double? _expectedRemaining;

  Map<int, List<Expense>> monthlyExpensesMap = {};
  Map<int, List<Income>> monthlyIncomesMap = {};

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _loadCategories();
    _fetchExpensesForYear(DateTime.now().year);
    _fetchIncomesForYear(DateTime.now().year);
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

  Future<void> _fetchIncomesForYear(int year) async {
    List<Income> yearlyIncomes = await _incomesDao.getIncomesByYear(year);
    setState(() {
      // incomes by month
      monthlyIncomesMap = {};
      for (var income in yearlyIncomes) {
        int month = income.date.month;
        monthlyIncomesMap.putIfAbsent(month, () => []).add(income);
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

                        // Update current available balance
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
         title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_money, size: 32,),
             SizedBox(width: 8), 
            Text('Finances'),
            
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFinanceOverview(),
            Divider(height: 2, thickness: 2),
            ListTile(
              leading: Icon(Icons.trending_down), 
              title: Text('Expenses', style: Theme.of(context).textTheme.headline6),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: _showAddExpenseSheet,
              ),
            ),
            _buildExpensesSection(),
            LPBarChart(monthlyExpenses: _calculateMonthlyExpenseTotals(), title: "Yearly Expenses"),
            SizedBox(height: 20),
            Divider(height: 2, thickness: 2),
            ListTile(
              leading: Icon(Icons.trending_up), 
              title: Text('Incomes', style: Theme.of(context).textTheme.headline6),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: _showAddIncomeSheet, 
              ),
            ),
            _buildIncomesSection(), 
            LPBarChart(monthlyExpenses: _calculateMonthlyIncomeTotals(), title: "Yearly Incomes"),
            SizedBox(height: 20),
            Divider(height: 2, thickness: 2),
            ListTile(
              leading: Icon(Icons.savings),  
              title: Text('Savings', style: Theme.of(context).textTheme.headline6),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: _showAddSavingSheet,
              ),
            ),
            _buildSavingsSection(),
            SizedBox(height: 20),
            Divider(height: 2, thickness: 2),
            ListTile(
              leading: Icon(Icons.account_balance_wallet), 
              title: Text('Budget', style: Theme.of(context).textTheme.headline6),
            ),
            _buildBudgetSection(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSection() {
  return FutureBuilder<Budget>(
    future: _budgetDao.getBudgetByMonth(DateTime.now().month),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text("Error: ${snapshot.error}");
      } else if (snapshot.hasData) {
        Budget currentBudget = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("Total Budget for ${currentBudget.month.name}", style: Theme.of(context).textTheme.headline6),
              subtitle: Text("Planned Expenses: \$${currentBudget.totalExpenseExpected.toStringAsFixed(2)}\nPlanned Incomes: \$${currentBudget.totalIncomeExpected.toStringAsFixed(2)}"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5), // Ensure this is consistent
              child: _buildExpensesBudgetCategoryTable(currentBudget),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5), // Ensure this is consistent
              child: _buildIncomesBudgetCategoryTable(currentBudget),
            ),
            ElevatedButton(
              onPressed: () => _showAddBudgetExpenseCategoryDialog(),
              child: Text('Manage Budget Expenses Categories'),
            ),
            ElevatedButton(
              onPressed: () => _showAddBudgetIncomeCategoryDialog(),
              child: Text('Manage Budget Incomes Categories'),
            ),
          ],
        );
      } else {
        return Text("No budget data available for the current month.");
      }
    },
  );
}


  Widget _buildIncomesBudgetCategoryTable(Budget currentBudget) {
    return FutureBuilder<Map<int, String>>(
      future: _budgetDao.getCategoryNamesByIds([...currentBudget.budgetIncomes.keys, ...currentBudget.budgetIncomes.keys]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error loading categories: ${snapshot.error}");
        } else if (snapshot.hasData) {
          var categoryNames = snapshot.data!;
          List<DataRow> rows = [];
          currentBudget.budgetIncomes.forEach((categoryId, planned) {
            Future<double> actualIncomes = _incomesDao.getTotalIncomesByCategory(categoryId);

            rows.add(
              DataRow(cells: [
                DataCell(Text(categoryNames[categoryId] ?? "Unknown Category", style: TextStyle(fontSize: 15))),
                DataCell(Text("\$${planned.toStringAsFixed(2)}", style: TextStyle(fontSize: 15))),
                DataCell(FutureBuilder<double>(
                  future: actualIncomes,
                  builder: (context, expSnapshot) {
                    if (expSnapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading...", style: TextStyle(fontSize: 15));
                    }
                    double actual = expSnapshot.hasData ? expSnapshot.data! : 0.0;
                    return Text("\$${actual.toStringAsFixed(2)}", style: TextStyle(fontSize: 15));
                  },
                )),
                DataCell(FutureBuilder<double>(
                  future: actualIncomes,
                  builder: (context, expSnapshot) {
                    if (expSnapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading...", style: TextStyle(fontSize: 15));
                    }
                    double actual = expSnapshot.hasData ? expSnapshot.data! : 0.0;
                    double variance = planned - actual;
                    return Text("\$${variance.toStringAsFixed(2)}", style: TextStyle(fontSize: 15));
                  },
                )),
              ])
            );
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Budgeted Incomes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              DataTable(
                columnSpacing: 25.0,
                columns: [
                  DataColumn(label: Text('Category', style: TextStyle(fontSize: 15))),
                  DataColumn(label: Text('Planned', style: TextStyle(fontSize: 15))),
                  DataColumn(label: Text('Actual', style: TextStyle(fontSize: 15))),
                  DataColumn(label: Text('Variance', style: TextStyle(fontSize: 15))),
                ],
                rows: rows
              ),
            ],
          );
        } else {
          return Text("No categories found.");
        }
      },
    );
  }

  Widget _buildExpensesBudgetCategoryTable(Budget currentBudget) {
    return FutureBuilder<Map<int, String>>(
      future: _budgetDao.getCategoryNamesByIds([...currentBudget.budgetExpenses.keys, ...currentBudget.budgetIncomes.keys]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error loading categories: ${snapshot.error}");
        } else if (snapshot.hasData) {
          var categoryNames = snapshot.data!;
          List<DataRow> rows = [];
          currentBudget.budgetExpenses.forEach((categoryId, planned) {
            Future<double> actualExpenses = _expensesDao.getTotalExpensesByCategory(categoryId);

            rows.add(
              DataRow(cells: [
                DataCell(Text(categoryNames[categoryId] ?? "Unknown Category", style: TextStyle(fontSize: 15))),
                DataCell(Text("\$${planned.toStringAsFixed(2)}", style: TextStyle(fontSize: 15))),
                DataCell(FutureBuilder<double>(
                  future: actualExpenses,
                  builder: (context, expSnapshot) {
                    if (expSnapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading...", style: TextStyle(fontSize: 15));
                    }
                    double actual = expSnapshot.hasData ? expSnapshot.data! : 0.0;
                    return Text("\$${actual.toStringAsFixed(2)}", style: TextStyle(fontSize: 15));
                  },
                )),
                DataCell(FutureBuilder<double>(
                  future: actualExpenses,
                  builder: (context, expSnapshot) {
                    if (expSnapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading...", style: TextStyle(fontSize: 15));
                    }
                    double actual = expSnapshot.hasData ? expSnapshot.data! : 0.0;
                    double variance = planned - actual;
                    return Text("\$${variance.toStringAsFixed(2)}", style: TextStyle(fontSize: 15));
                  },
                )),
              ])
            );
          });

          // Wrap the DataTable within a Column to add the title
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Budgeted Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              DataTable(
                columnSpacing: 25.0,
                columns: [
                  DataColumn(label: Text('Category', style: TextStyle(fontSize: 15))),
                  DataColumn(label: Text('Planned', style: TextStyle(fontSize: 15))),
                  DataColumn(label: Text('Actual', style: TextStyle(fontSize: 15))),
                  DataColumn(label: Text('Variance', style: TextStyle(fontSize: 15))),
                ],
                rows: rows
              ),
            ],
          );
        } else {
          return Text("No categories found.");
        }
      },
    );
  }




  void _showAddBudgetExpenseCategoryDialog() async {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _amountController = TextEditingController();
    int? _selectedCategoryId;
    List<Map<String, dynamic>> categories = await _budgetDao.getAllBudgetCategories();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category to Budget Expenses'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        hint: Text("Select Category"),
                        onChanged: (int? newValue) {
                          _selectedCategoryId = newValue;
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                        items: categories.map<DropdownMenuItem<int>>((Map<String, dynamic> category) {
                          return DropdownMenuItem<int>(
                            value: category['id'],
                            child: Text(category['category']),
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  _addExpenseCategoryToBudget(_selectedCategoryId!, double.parse(_amountController.text));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddBudgetIncomeCategoryDialog() async {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _amountController = TextEditingController();
    int? _selectedCategoryId;
    List<Map<String, dynamic>> categories = await _budgetDao.getAllBudgetCategories();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category to Budget Incomes'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        hint: Text("Select Category"),
                        onChanged: (int? newValue) {
                          _selectedCategoryId = newValue;
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                        items: categories.map<DropdownMenuItem<int>>((Map<String, dynamic> category) {
                          return DropdownMenuItem<int>(
                            value: category['id'],
                            child: Text(category['category']),
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  _addIncomeCategoryToBudget(_selectedCategoryId!, double.parse(_amountController.text));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addIncomeCategoryToBudget(int categoryId, double amount) async {
    Budget currentBudget = await _budgetDao.getBudgetByMonth(DateTime.now().month);
    currentBudget.budgetIncomes[categoryId] = amount;
    currentBudget.totalIncomeExpected += amount;
    await _budgetDao.updateBudget(currentBudget);

    setState(() {});  // Refresh 
  }

  void _addExpenseCategoryToBudget(int categoryId, double amount) async {
    Budget currentBudget = await _budgetDao.getBudgetByMonth(DateTime.now().month);
    currentBudget.budgetExpenses[categoryId] = amount;
    currentBudget.totalExpenseExpected += amount;
    await _budgetDao.updateBudget(currentBudget);

    setState(() {});  // Refresh 
  }


  Widget _buildSavingsSection() {
    return FutureBuilder<List<Saving>>(
      future: _savingsDao.getAllSavings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading savings'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return ListTile(title: Text('No savings recorded'));
        } else {
          return ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: snapshot.data!.map((saving) {
              return ExpansionTile(
                leading: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _showAddContributionDialog(context, saving),
                ),
                title: Text(saving.name),
                subtitle: Text('${saving.description}\n${saving.currentSaved.toStringAsFixed(2)}/${saving.targetAmount.toStringAsFixed(2)}'),
                children: [
                  _buildContributionsList(saving),
                ],
              );
            }).toList(),
          );
        }
      },
    );
  }

 void _showAddContributionDialog(BuildContext context, Saving saving) {
  final _amountController = TextEditingController();
  String? errorMessage; 

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder( 
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Add Contribution"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: "Enter amount",
                    errorText: errorMessage, 
                  ),
                ),
                
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Add'),
                onPressed: () async {
                  double? amount = double.tryParse(_amountController.text);
                  var currentBalance = await _balanceDao.getBalance();
                  if (amount == null || amount <= 0) {
                    setState(() {
                      errorMessage = "Please enter a valid amount";
                    });
                  } else if (currentBalance!.currentAvailable < amount) {
                    setState(() {
                      errorMessage = "Not enough money available"; // Establecer mensaje de error
                    });
                  } else {
                    saving.addContribution(DateTime.now(), amount);
                    
                    // Update current available balance
                    currentBalance.currentAvailable -= amount;
                    await _balanceDao.setBalance(currentBalance);
                    _loadBalance();  

                    // Update the saving in the database and UI
                    _savingsDao.updateSaving(saving).then((_) {
                      Navigator.of(context).pop();
                      setState(() {}); // Actualizar UI después de guardar cambios
                    });
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}




  Widget _buildContributionsList(Saving saving) {
    if (saving.contributions.isEmpty) {
      return ListTile(title: Text("No contributions yet"));
    }
    return Column(
      children: saving.contributions.entries.map((entry) {
        return ListTile(
          title: Text(DateFormat('yyyy-MM-dd').format(entry.key)),
          subtitle: Text('\$${entry.value.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () async {
              saving.contributions.remove(entry.key);
              // Update total saved amount
              saving.currentSaved -= entry.value;
              // Update the saving in the database
              await _savingsDao.updateSaving(saving);
              
              // Update current available balance
              var currentBalance = await _balanceDao.getBalance();
              if (currentBalance != null) {
                currentBalance.currentAvailable += entry.value;
                await _balanceDao.setBalance(currentBalance);
                _loadBalance();
              }
              setState(() {});
            },
          ),
        );
      }).toList(),
    );
  }


void _showAddSavingSheet() {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

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
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Saving Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a saving name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _targetAmountController,
                  decoration: InputDecoration(labelText: 'Target Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Saving newSaving = Saving(
                        name: _nameController.text,
                        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                        targetAmount: double.parse(_targetAmountController.text),
                        currentSaved: 0.0, // Initially, no money saved
                        contributions: {},
                      );
                      _savingsDao.addSaving(newSaving);
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: Text('Add Saving'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}



  void _showAddIncomeSheet() {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  bool _isBudgetedIncome = false;
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
                  controller: _sourceController,
                  decoration: InputDecoration(labelText: 'Source'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a source';
                    }
                    return null;
                  },
                ),
                SwitchListTile(
                  title: Text("Is it a budgeted income?"),
                  value: _isBudgetedIncome,
                  onChanged: (bool value) {
                    setState(() {
                      _isBudgetedIncome = value;
                    });
                  },
                ),
                if (_isBudgetedIncome)
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
                      Income newIncome = Income(
                        date: date,
                        amount: amount,
                        concept: _sourceController.text,
                        budget_or_not: _isBudgetedIncome,
                        category_id: _selectedCategoryId, 
                      );
                      _incomesDao.addIncome(newIncome);
                      
                      // Update current available balance
                      var currentBalance = await _balanceDao.getBalance();
                      if (currentBalance != null) {
                        currentBalance.currentAvailable += amount;
                        await _balanceDao.setBalance(currentBalance);
                        _loadBalance();
                      }
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: Text('Add Income'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomesSection() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return FutureBuilder<List<Income>>(
      future: _incomesDao.getAllIncomes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading incomes'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return ListTile(title: Text('No incomes recorded'));
        } else {
          var thisMonthIncomes = snapshot.data!
              .where((income) => income.date.isAfter(startOfMonth) || income.date.isAtSameMomentAs(startOfMonth))
              .toList();

          if (thisMonthIncomes.isEmpty) {
            return ListTile(title: Text('No incomes this month'));
          }

          return ExpansionTile(
            title: Text("View this month's incomes"),
            initiallyExpanded: false,
            children: thisMonthIncomes.map((income) => ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('${income.concept} - \$${income.amount.toStringAsFixed(2)}'),
              subtitle: Text('Date: ${DateFormat('yyyy-MM-dd').format(income.date)}'),
              trailing: IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () async {
                  await _incomesDao.deleteIncome(income.id!);
                  // Update current available balance
                  var currentBalance = await _balanceDao.getBalance();
                  if (currentBalance != null) {
                    currentBalance.currentAvailable -= income.amount;
                    await _balanceDao.setBalance(currentBalance);
                    _loadBalance();
                  }
                  setState(() {});
                },
              ),
            )).toList(),
          );
        }
      },
    );
  }

  List<double> _calculateMonthlyExpenseTotals() {
    return List.generate(12, (index) {
      return monthlyExpensesMap[index + 1]?.fold(0.0, (prev, expense) => prev! + expense.amount) ?? 0.0;
    });
  }

  List<double> _calculateMonthlyIncomeTotals() {
    return List.generate(12, (index) {
      return monthlyIncomesMap[index + 1]?.fold(0.0, (prev, income) => prev! + income.amount) ?? 0.0;
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
            trailing: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () async {
                await _expensesDao.deleteExpense(expense.id!);

                // update balance
                var currentBalance = await _balanceDao.getBalance();
                if (currentBalance != null) {
                  currentBalance.currentAvailable += expense.amount;
                  await _balanceDao.setBalance(currentBalance);
                  _loadBalance();
                }

                setState(() {});
              },
            ),
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


class LPBarChart extends StatelessWidget {
  final List<double> monthlyExpenses;
  String title;

  LPBarChart({Key? key, required this.monthlyExpenses, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            title,
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

