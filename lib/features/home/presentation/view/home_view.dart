import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/widgets/dashboard/dashboard_actions.dart';
import 'package:sincro/core/widgets/dashboard/dashboard_balance_card.dart';
import 'package:sincro/core/widgets/dashboard/dashboard_chart.dart';
import 'package:sincro/core/widgets/dashboard/recent_transactions_list.dart';
import 'package:sincro/features/home/presentation/viewmodels/home_viewmodel.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                state.balance.when(
                  data: (balance) => DashboardBalanceCard(balance: balance),
                  loading: () => const DashboardBalanceCard(isLoading: true),
                  error: (_, __) =>
                      const DashboardBalanceCard(isLoading: false),
                ),
                const SizedBox(height: 24),

                state.chartData.when(
                  data: (data) => DashboardChart(chartData: data.chartData),
                  loading: () =>
                      const DashboardChart(chartData: [], isLoading: true),
                  error: (_, __) =>
                      const DashboardChart(chartData: [], isLoading: false),
                ),
                const SizedBox(height: 24),

                const DashboardActions(),
                const SizedBox(height: 32),

                RecentTransactionsList(
                  transactionsAsync: state.recentTransactions,
                  onRetry: () => viewModel.refresh(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
