import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/constants/transaction_categories.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/features/profile/profile_providers.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/history/history_state.dart';
import 'package:sincro/features/transactions/transactions_providers.dart';

part 'history_viewmodel.g.dart';

@riverpod
class HistoryViewModel extends _$HistoryViewModel {
  @override
  Future<HistoryState> build() async {
    final groupLoadFuture = _loadAvailableGroups();
    final transactionsFuture = _fetchTransactions(
      page: 1,
      stateCopy: const HistoryState(),
    );

    final results = await Future.wait([groupLoadFuture, transactionsFuture]);

    final groups = results[0] as List<GroupModel>;
    final initialState = results[1] as HistoryState;

    return initialState.copyWith(availableGroups: groups);
  }

  List<String> get availableCategories {
    final type = state.value?.typeFilter;
    if (type == TransactionType.income) return TransactionCategories.income;
    if (type == TransactionType.expense) return TransactionCategories.expense;
    return TransactionCategories.getAll();
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncData(
      currentState.copyWith(isLoadingMore: true, loadMoreError: null),
    );

    final nextPage = currentState.page + 1;

    try {
      final newState = await _fetchTransactions(
        page: nextPage,
        stateCopy: currentState,
        isPagination: true,
      );
      state = AsyncData(newState);
    } catch (e) {
      state = AsyncData(
        currentState.copyWith(
          isLoadingMore: false,
          loadMoreError: 'Erro ao carregar mais itens',
        ),
      );
    }
  }

  Future<void> updateFilters({
    String? search,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? groupIds,
    List<String>? categories,
  }) async {
    final currentState = state.value ?? const HistoryState();

    List<String> newCategories = categories ?? currentState.selectedCategories;

    if (type != null && type != currentState.typeFilter) {
      newCategories = [];
    }

    final baseState = currentState.copyWith(
      isRefreshingFilters: true,
      searchQuery: search ?? currentState.searchQuery,
      typeFilter: type ?? currentState.typeFilter,
      startDate: startDate ?? currentState.startDate,
      endDate: endDate ?? currentState.endDate,
      selectedGroupIds: groupIds ?? currentState.selectedGroupIds,

      selectedCategories: newCategories,

      page: 1,
    );

    state = AsyncData(baseState);

    try {
      final newState = await _fetchTransactions(page: 1, stateCopy: baseState);
      state = AsyncData(newState.copyWith(isRefreshingFilters: false));
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> setTypeFilter(TransactionType? type) async {
    final currentState = state.value ?? const HistoryState();
    final baseState = currentState.copyWith(
      isRefreshingFilters: true,
      typeFilter: type,
      selectedCategories: [],
      page: 1,
    );

    state = AsyncData(baseState);
    _executeRefresh(baseState);
  }

  Future<void> clearDateFilter() async {
    final currentState = state.value ?? const HistoryState();
    final baseState = currentState.copyWith(
      isRefreshingFilters: true,
      startDate: null,
      endDate: null,
      page: 1,
    );

    state = AsyncData(baseState);
    _executeRefresh(baseState);
  }

  Future<void> clearAllFilters() async {
    final currentState = state.value ?? const HistoryState();
    final baseState = currentState.copyWith(
      isRefreshingFilters: true,
      searchQuery: '',
      typeFilter: null,
      startDate: null,
      endDate: null,
      selectedGroupIds: [],
      selectedCategories: [],
      page: 1,
    );

    state = AsyncData(baseState);
    _executeRefresh(baseState);
  }

  Future<void> refresh() async {
    final currentState = state.value;
    if (currentState == null) return;

    final baseState = currentState.copyWith(isRefreshingFilters: true, page: 1);
    state = AsyncData(baseState);
    _executeRefresh(baseState);
  }

  Future<void> _executeRefresh(HistoryState baseState) async {
    try {
      final newState = await _fetchTransactions(page: 1, stateCopy: baseState);
      state = AsyncData(newState.copyWith(isRefreshingFilters: false));
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<HistoryState> _fetchTransactions({
    required int page,
    required HistoryState stateCopy,
    bool isPagination = false,
  }) async {
    final repository = ref.read(transactionRepositoryProvider);

    final result = await repository
        .getTransactions(
          page: page,
          search: stateCopy.searchQuery,
          type: stateCopy.typeFilter,
          startDate: stateCopy.startDate,
          endDate: stateCopy.endDate,
          groupIds: stateCopy.selectedGroupIds,
          categories: stateCopy.selectedCategories,
        )
        .run();

    return result.fold(
      (failure) => throw failure,
      (response) {
        final newTransactions = response.data;
        final meta = response.meta;

        return stateCopy.copyWith(
          transactions: isPagination
              ? [...stateCopy.transactions, ...newTransactions]
              : newTransactions,
          page: meta.currentPage,
          hasMore: meta.currentPage < meta.lastPage,
          isLoadingMore: false,
          loadMoreError: null,
        );
      },
    );
  }

  Future<List<GroupModel>> _loadAvailableGroups() async {
    final profileRepository = ref.read(profileRepositoryProvider);
    final result = await profileRepository.getMyGroups().run();
    return result.getOrElse((_) => []);
  }
}
