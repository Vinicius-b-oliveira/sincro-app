import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:sincro/core/enums/transaction_type.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
abstract class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    required int id,
    required String title,
    String? description,
    required double amount,
    required TransactionType type,

    @JsonKey(name: 'category') @Default('Outros') String category,

    @JsonKey(name: 'transaction_date') required DateTime date,

    @JsonKey(name: 'created_at') required DateTime createdAt,

    @JsonKey(name: 'user_id') required int userId,

    @JsonKey(name: 'user_name') required String userName,

    @JsonKey(name: 'group_id') int? groupId,

    @JsonKey(name: 'group_name') String? groupName,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  String get formattedAmount {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(amount);
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  bool isOwnedBy(int currentUserId) => userId == currentUserId;
}
