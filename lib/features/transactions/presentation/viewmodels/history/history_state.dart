import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/transaction_model.dart';

part 'history_state.freezed.dart';

@freezed
abstract class HistoryState with _$HistoryState {
  const factory HistoryState({
    @Default([]) List<TransactionModel> transactions,
    @Default(1) int page,
    @Default(true) bool hasMore,
    @Default(false) bool isLoadingMore,

    @Default(false) bool isRefreshingFilters,

    String? searchQuery,
    TransactionType? typeFilter,
    DateTime? startDate,
    DateTime? endDate,

    @Default([]) List<int> selectedGroupIds,
    @Default([]) List<String> selectedCategories,

    @Default([]) List<GroupModel> availableGroups,

    String? loadMoreError,
  }) = _HistoryState;
}
