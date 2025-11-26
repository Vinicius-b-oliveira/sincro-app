import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';
import 'package:sincro/core/models/balance_model.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/features/analytics/analytics_providers.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_detail/group_detail_state.dart';
import 'package:sincro/features/home/home_providers.dart';

part 'group_detail_viewmodel.g.dart';

@riverpod
class GroupDetailViewModel extends _$GroupDetailViewModel {
  @override
  GroupDetailState build(String groupId) {
    Future.microtask(() => refresh());
    return const GroupDetailState();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      groupData: const AsyncValue.loading(),
      balance: const AsyncValue.loading(),
      recentTransactions: const AsyncValue.loading(),
      chartData: const AsyncValue.loading(),
    );

    final idAsInt = int.tryParse(groupId);
    if (idAsInt == null) {
      state = state.copyWith(
        groupData: AsyncValue.error('ID de grupo inválido', StackTrace.current),
      );
      return;
    }

    final groupsRepo = ref.read(groupsRepositoryProvider);
    final homeRepo = ref.read(homeRepositoryProvider);
    final analyticsRepo = ref.read(analyticsRepositoryProvider);

    final groupFuture = groupsRepo.getGroup(groupId).run();

    final balanceFuture = homeRepo.getBalance(groupId: idAsInt).run();

    final recentsFuture = groupsRepo
        .getGroupTransactions(
          groupId: groupId,
          page: 1,
        )
        .run();
    final chartFuture = analyticsRepo
        .getSummary(
          period: '1y',
          groupId: idAsInt,
        )
        .run();

    final results = await Future.wait([
      groupFuture,
      balanceFuture,
      recentsFuture,
      chartFuture,
    ]);

    results[0].fold(
      (failure) => state = state.copyWith(
        groupData: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (data) => state = state.copyWith(
        groupData: AsyncValue.data(data as GroupModel),
      ),
    );

    results[1].fold(
      (failure) => state = state.copyWith(
        balance: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (data) => state = state.copyWith(
        balance: AsyncValue.data(data as BalanceModel),
      ),
    );

    results[2].fold(
      (failure) => state = state.copyWith(
        recentTransactions: AsyncValue.error(
          failure.message,
          StackTrace.current,
        ),
      ),
      (data) {
        final paginated = data as PaginatedResponse<TransactionModel>;
        state = state.copyWith(
          recentTransactions: AsyncValue.data(paginated.data.take(5).toList()),
        );
      },
    );

    results[3].fold(
      (failure) => state = state.copyWith(
        chartData: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (data) => state = state.copyWith(
        chartData: AsyncValue.data(data as AnalyticsSummaryModel),
      ),
    );
  }
}
