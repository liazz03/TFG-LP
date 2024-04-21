class Income {
  int? id;
  DateTime date;
  double amount;
  String concept;
  bool budget_or_not;
  int category_id;

  Income({this.id, required this.date, required this.amount, required this.concept, required this.budget_or_not, required this.category_id});


  Map<String, dynamic> toMap() {
    var map = {
      'id': id, 
      'date': date.toIso8601String(), // Convert DateTime to ISO8601 String
      'amount': amount,
      'concept': concept,
      'budget_or_not': budget_or_not ? 1 : 0, // Convert bool to int
      'category_id': category_id,
    };
    
    return map;
  }

  static Income fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      date: DateTime.parse(map['date']), // Convert String to DateTime
      amount: map['amount'],
      concept: map['concept'],
      budget_or_not: map['budget_or_not'] == 1, // Convert int to bool
      category_id: map['category_id'],
    );
  }
}
