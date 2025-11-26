import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:sincro/core/models/balance_model.dart';

class DashboardBalanceCard extends HookWidget {
  final BalanceModel? balance;
  final bool isLoading;

  const DashboardBalanceCard({
    this.balance,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isVisible = useState(true);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final totalBalance = balance?.totalBalance ?? 0.0;
    final formattedBalance = currency.format(totalBalance);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo atual',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isLoading)
                    Container(
                      width: 140,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                  else
                    Text(
                      isVisible.value ? formattedBalance : 'R\$ ••••••••••',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isVisible.value
                            ? (totalBalance >= 0
                                  ? colorScheme.primary
                                  : colorScheme.error)
                            : colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () => isVisible.value = !isVisible.value,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
                icon: Icon(
                  isVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
            ],
          ),

          if (!isLoading && balance != null && isVisible.value) ...[
            const SizedBox(height: 16),
            Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  context,
                  'Entradas',
                  balance!.periodIncome,
                  Colors.green,
                  Icons.arrow_upward,
                ),
                _buildSummaryItem(
                  context,
                  'Saídas',
                  balance!.periodExpenses,
                  Colors.red,
                  Icons.arrow_downward,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.compactSimpleCurrency(locale: 'pt_BR');

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelSmall),
            Text(
              currency.format(value),
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
