import 'package:intl/intl.dart';

class Expense {
  int? id;
  DateTime date;
  double amount;
  String concept;
  bool budget_or_not;
  int? categoryId;

  Expense({
    this.id,
    required this.date, 
    required this.amount, 
    required this.concept, 
    required this.budget_or_not,
    this.categoryId,
  });

  Map<String, dynamic> toMap() {
    var map = {
      'date': DateFormat('yyyy-MM-dd').format(date), 
      'amount': amount,
      'concept': concept,
      'budget_or_not': budget_or_not ? 1 : 0, 
      'category_id': categoryId, 
    };

    if (id != null){
      map['id'] = id!;
    }
    
    return map;
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      concept: map['concept'],
      budget_or_not: map['budget_or_not'] == 1, 
      categoryId: map['category_id'],
    );
  }

  @override
  String toString() {
    return 'Income{date: $date, amount: $amount, concept: $concept}';
  }
}