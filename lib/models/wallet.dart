class Wallet {
  final int? id;
  final String name;
  final double balance;
  final String currency;
  final DateTime createdAt;

  Wallet({
    this.id,
    required this.name,
    required this.balance,
    this.currency = 'VND',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] as int?,
      name: map['name'] as String,
      balance: map['balance'] as double,
      currency: map['currency'] as String? ?? 'VND',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
