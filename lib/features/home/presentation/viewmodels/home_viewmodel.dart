import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';
import 'package:sincro/core/models/balance_model.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/features/analytics/analytics_providers.dart';
import 'package:sincro/features/home/home_providers.dart';
import 'package:sincro/features/home/presentation/viewmodels/home_state.dart';
import 'package:sincro/features/transactions/transactions_providers.dart';

part 'home_viewmodel.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    Future.microtask(() => refresh());
    return const HomeState();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      balance: const AsyncValue.loading(),
      recentTransactions: const AsyncValue.loading(),
      chartData: const AsyncValue.loading(),
    );

    final homeRepo = ref.read(homeRepositoryProvider);
    final transactionRepo = ref.read(transactionRepositoryProvider);
    final analyticsRepo = ref.read(analyticsRepositoryProvider);

    final balanceFuture = homeRepo.getBalance().run();
    final recentsFuture = transactionRepo.getTransactions(page: 1).run();

    final chartFuture = analyticsRepo.getSummary(period: '1y').run();

    final results = await Future.wait([
      balanceFuture,
      recentsFuture,
      chartFuture,
    ]);

    results[0].fold(
      (failure) => state = state.copyWith(
        balance: AsyncValue.error(failure, StackTrace.current),
      ),
      (data) => state = state.copyWith(
        balance: AsyncValue.data(data as BalanceModel),
      ),
    );

    results[1].fold(
      (failure) => state = state.copyWith(
        recentTransactions: AsyncValue.error(failure, StackTrace.current),
      ),
      (data) {
        final paginated = data as PaginatedResponse<TransactionModel>;
        state = state.copyWith(
          recentTransactions: AsyncValue.data(paginated.data.take(5).toList()),
        );
      },
    );

    results[2].fold(
      (failure) => state = state.copyWith(
        chartData: AsyncValue.error(failure, StackTrace.current),
      ),
      (data) => state = state.copyWith(
        chartData: AsyncValue.data(data as AnalyticsSummaryModel),
      ),
    );
  }
}
