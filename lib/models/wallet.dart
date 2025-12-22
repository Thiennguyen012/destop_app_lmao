class Wallet {
  final int? id;
  final int? userId;
  final String name;
  final double balance;
  final String currency;
  final DateTime createdAt;

  Wallet({
    this.id,
    this.userId,
    required this.name,
    required this.balance,
    this.currency = 'VND',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'balance': balance,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] as int?,
      userId: map['userId'] as int?,
      name: map['name'] as String,
      balance: map['balance'] as double,
      currency: map['currency'] as String? ?? 'VND',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Wallet copyWith({
    int? id,
    int? userId,
    String? name,
    double? balance,
    String? currency,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
