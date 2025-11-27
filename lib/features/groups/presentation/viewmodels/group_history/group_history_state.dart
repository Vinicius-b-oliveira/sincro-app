import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/transaction_model.dart';

part 'group_history_state.freezed.dart';

@freezed
abstract class GroupHistoryState with _$GroupHistoryState {
  const factory GroupHistoryState({
    @Default([]) List<TransactionModel> transactions,
    @Default(1) int page,
    @Default(true) bool hasMore,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    String? error,
  }) = _GroupHistoryState;
}
