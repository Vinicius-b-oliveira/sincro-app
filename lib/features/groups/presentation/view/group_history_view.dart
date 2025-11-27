import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/widgets/transaction_list_item.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_history/group_history_viewmodel.dart';

class GroupHistoryView extends HookConsumerWidget {
  final String groupId;
  final String groupName;

  const GroupHistoryView({
    required this.groupId,
    this.groupName = 'Histórico do Grupo',
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = groupHistoryViewModelProvider(groupId);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    final scrollController = useScrollController();

    useEffect(() {
      void listener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          viewModel.loadNextPage();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          groupName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.transactions.isEmpty
            ? _buildEmptyState(context, colorScheme)
            : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.transactions.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final transaction = state.transactions[index];
                  return TransactionListItem(
                    transaction: transaction,
                    showMemberName: true,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_edu_outlined,
            size: 64,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação encontrada',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
