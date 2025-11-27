import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/routing/app_routes.dart';
import 'package:sincro/core/widgets/dashboard/dashboard_balance_card.dart';
import 'package:sincro/core/widgets/dashboard/dashboard_chart.dart';
import 'package:sincro/core/widgets/transaction_list_item.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_detail/group_detail_viewmodel.dart';
import 'package:sincro/features/groups/presentation/widgets/invite_user_bottom_sheet.dart';
import 'package:sincro/features/groups/presentation/widgets/manage_group_bottom_sheet.dart';

class GroupDetailView extends HookConsumerWidget {
  final String groupId;
  const GroupDetailView({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = groupDetailViewModelProvider(groupId);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: state.groupData.when(
          data: (group) => Text(
            group.name,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          loading: () => const Text('Carregando...'),
          error: (_, __) => const Text('Grupo'),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                state.groupData.when(
                  data: (group) => _buildGroupActions(
                    context,
                    group,
                    colorScheme,
                  ),
                  loading: () => const SizedBox(height: 48),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

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

                state.groupData.when(
                  data: (group) => _buildPrimaryActions(
                    context,
                    group,
                    colorScheme,
                    textTheme,
                  ),
                  loading: () => const SizedBox(height: 50),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Histórico Recente',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final groupName =
                            state.groupData.asData?.value.name ?? 'Grupo';

                        context.pushNamed(
                          AppRoutes.groupHistory,
                          pathParameters: {'id': groupId},
                          queryParameters: {'name': groupName},
                        );
                      },
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                state.recentTransactions.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: colorScheme.outline.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nenhuma transação recente',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: transactions
                          .map(
                            (t) => TransactionListItem(
                              transaction: t,
                              showMemberName: true,
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Erro: $err')),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupActions(
    BuildContext context,
    GroupModel group,
    ColorScheme colorScheme,
  ) {
    final canInvite =
        group.role.isOwner ||
        group.role.isAdmin ||
        (group.role.isMember && group.membersCanInvite);

    final canManage = group.role.isOwner || group.role.isAdmin;

    if (!canInvite && !canManage) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (canInvite)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const InviteUserBottomSheet(),
              ),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Convidar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        if (canInvite && canManage) const SizedBox(width: 12),

        if (canManage)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ManageGroupBottomSheet(
                  groupName: group.name,
                  groupId: groupId,
                ),
              ),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Gerenciar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrimaryActions(
    BuildContext context,
    GroupModel group,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final canAddTransaction =
        group.role.isOwner ||
        group.role.isAdmin ||
        (group.role.isMember && group.membersCanAddTransactions);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: canAddTransaction
                ? () => context.pushNamed(
                    AppRoutes.addTransaction,
                    extra: group.id,
                  )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: colorScheme.onSurface.withValues(
                alpha: 0.12,
              ),
              disabledForegroundColor: colorScheme.onSurface.withValues(
                alpha: 0.38,
              ),
            ),
            child: Text(
              canAddTransaction ? 'Adicionar transação' : 'Sem permissão',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: canAddTransaction
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => context.push(
            '${AppRoutes.analytics}?groupId=$groupId',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.analytics, size: 20),
          label: const Text('Análises'),
        ),
      ],
    );
  }
}
