import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
