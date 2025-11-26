import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/core/widgets/transaction_list_item.dart';

class RecentTransactionsList extends ConsumerWidget {
  final AsyncValue<List<TransactionModel>> transactionsAsync;
  final VoidCallback? onRetry;

  const RecentTransactionsList({
    required this.transactionsAsync,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Histórico Recente',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        transactionsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.grey),
                const SizedBox(height: 8),
                Text('Erro ao carregar: $err'),
                if (onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Tentar novamente'),
                  ),
              ],
            ),
          ),
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
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhuma transação recente',
                        style: theme.textTheme.bodyMedium?.copyWith(
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
                  .map((t) => TransactionListItem(transaction: t))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
