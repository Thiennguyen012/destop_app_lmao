class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final String? description;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as double,
      category: map['category'] as String,
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
    );
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? type,
    DateTime? date,
    String? description,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
