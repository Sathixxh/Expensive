

class Expense {
  final DateTime date;
  final String type;
  final double amount;

  Expense({required this.date, required this.type, required this.amount});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'type': type,
        'amount': amount,
      };

  static Expense fromJson(Map<String, dynamic> json) => Expense(
        date: DateTime.parse(json['date']),
        type: json['type'],
        amount: json['amount'],
      );
}
