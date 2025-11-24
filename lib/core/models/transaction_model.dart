import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

enum TransactionType {
  @JsonValue('income')
  income,
  @JsonValue('expense')
  expense;

  String get label => this == TransactionType.income ? 'Receita' : 'Despesa';

  Color get color => this == TransactionType.income
      ? const Color(0xFF4CAF50)
      : const Color(0xFFE53935);
}

@freezed
abstract class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    required int id,
    required String title,

    @JsonKey(fromJson: _stringToDouble, toJson: _doubleToString)
    required double amount,

    required TransactionType type,

    @JsonKey(name: 'category') @Default('Outros') String category,

    @JsonKey(name: 'transaction_date') required DateTime date,

    @JsonKey(name: 'group_id') int? groupId,

    String? description,

    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  String get formattedAmount {
    return amount.toStringAsFixed(2);
  }
}

double _stringToDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

String _doubleToString(double value) {
  return value.toStringAsFixed(2);
}
