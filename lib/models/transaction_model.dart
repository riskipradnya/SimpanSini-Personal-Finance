class Transaction {
  final int? id;
  final int userId;
  final String type; // 'income' or 'expense'
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  Transaction({
    this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      type: json['type'],
      category: json['category'],
      description: json['description'] ?? '',
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
    };
  }
}
