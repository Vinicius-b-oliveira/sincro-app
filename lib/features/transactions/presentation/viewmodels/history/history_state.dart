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

    String? searchQuery,
    TransactionType? typeFilter,
    DateTime? startDate,
    DateTime? endDate,
    int? selectedGroupId,

    @Default([]) List<String> selectedCategories,

    @Default([]) List<GroupModel> availableGroups,

    String? loadMoreError,
  }) = _HistoryState;
}
