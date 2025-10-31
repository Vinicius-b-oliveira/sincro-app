class Transaction {
  final int id;
  final String title;
  final String description;
  final String amount;
  final String type;
  final DateTime transactionDate;
  final DateTime createdAt;
  final bool isOwnedByUser;

  const Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.transactionDate,
    required this.createdAt,
    required this.isOwnedByUser,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: json['amount'] as String,
      type: json['type'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      isOwnedByUser: json['is_owned_by_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'type': type,
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_owned_by_user': isOwnedByUser,
    };
  }

  Transaction copyWith({
    int? id,
    String? title,
    String? description,
    String? amount,
    String? type,
    DateTime? transactionDate,
    DateTime? createdAt,
    bool? isOwnedByUser,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      isOwnedByUser: isOwnedByUser ?? this.isOwnedByUser,
    );
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  double get amountValue => double.tryParse(amount) ?? 0.0;
}
