import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_model.freezed.dart';
part 'balance_model.g.dart';

@freezed
abstract class BalanceModel with _$BalanceModel {
  const factory BalanceModel({
    @JsonKey(name: 'total_balance', fromJson: _stringToDouble)
    required double totalBalance,
    @JsonKey(name: 'period_income', fromJson: _stringToDouble)
    required double periodIncome,
    @JsonKey(name: 'period_expenses', fromJson: _stringToDouble)
    required double periodExpenses,
  }) = _BalanceModel;

  factory BalanceModel.fromJson(Map<String, dynamic> json) =>
      _$BalanceModelFromJson(json);
}

double _stringToDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
