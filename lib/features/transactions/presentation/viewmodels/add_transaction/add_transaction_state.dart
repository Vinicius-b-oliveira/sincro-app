import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/group_model.dart';

part 'add_transaction_state.freezed.dart';

@freezed
abstract class AddTransactionState with _$AddTransactionState {
  const factory AddTransactionState({
    @Default(false) bool isLoading,
    @Default([]) List<GroupModel> availableGroups,
    String? error,
    @Default(false) bool isSuccess,
  }) = _AddTransactionState;
}
