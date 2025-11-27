import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_history/group_history_state.dart';

part 'group_history_viewmodel.g.dart';

@riverpod
class GroupHistoryViewModel extends _$GroupHistoryViewModel {
  @override
  GroupHistoryState build(String groupId) {
    Future.microtask(() => refresh());
    return const GroupHistoryState();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      transactions: [],
      page: 1,
      hasMore: true,
    );

    await _fetchTransactions(page: 1);
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    await _fetchTransactions(page: state.page + 1);
  }

  Future<void> _fetchTransactions({required int page}) async {
    final repository = ref.read(groupsRepositoryProvider);

    final result = await repository
        .getGroupTransactions(
          groupId: groupId,
          page: page,
        )
        .run();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: failure.message,
        );
      },
      (paginated) {
        final newTransactions = paginated.data;
        final meta = paginated.meta;

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          transactions: page == 1
              ? newTransactions
              : [...state.transactions, ...newTransactions],
          page: meta.currentPage,
          hasMore: meta.currentPage < meta.lastPage,
        );
      },
    );
  }
}
