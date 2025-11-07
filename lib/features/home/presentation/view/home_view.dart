import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/routing/app_routes.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBalanceVisible = useState(true);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBalanceSection(
                context,
                textTheme,
                colorScheme,
                isBalanceVisible,
              ),
              const SizedBox(height: 24),

              _buildChartSection(context, colorScheme),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push(AppRoutes.addTransaction),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Adicionar transação',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.analytics),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    icon: const Icon(Icons.analytics, size: 20),
                    label: const Text('Análises'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildRecentHistory(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSection(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    ValueNotifier<bool> isBalanceVisible,
  ) {
    return Row(
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
            const SizedBox(height: 4),
            Text(
              isBalanceVisible.value ? 'R\$ 1.234,56' : 'R\$ ••••••••••',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => isBalanceVisible.value = !isBalanceVisible.value,
          style: TextButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(isBalanceVisible.value ? 'Ocultar' : 'Mostrar'),
        ),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context, ColorScheme colorScheme) {
    final chartData = [
      (label: 'contas', value: 500.0, color: colorScheme.secondary),
      (label: 'comida', value: 800.0, color: colorScheme.primary),
      (label: 'lazer', value: 300.0, color: colorScheme.secondary),
      (label: 'transporte', value: 600.0, color: colorScheme.primary),
      (label: 'outros', value: 450.0, color: colorScheme.secondary),
      (label: 'investimento', value: 900.0, color: colorScheme.primary),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => colorScheme.surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${chartData[groupIndex].label}\nR\$ ${rod.toY.toStringAsFixed(2)}',
                        TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                    tooltipBorder: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    tooltipPadding: const EdgeInsets.all(8),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < chartData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${value.toInt() + 1}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(
                  chartData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: chartData[index].value,
                        color: chartData[index].color,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              chartData.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${index + 1} ${chartData[index].label}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'R\$ ${chartData[index].value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentHistory(BuildContext context, ColorScheme colorScheme) {
    final recentTransactions = [
      (
        id: 1,
        name: 'Uber para casa',
        category: 'Transporte',
        location: 'Uber',
        date: '07 nov, 20:15',
        amount: 'R\$ 24,50',
        type: 'expense',
        group: 'Pessoal',
      ),
      (
        id: 2,
        name: 'Almoço no Restaurante',
        category: 'Alimentação',
        location: 'Restaurante',
        date: '07 nov, 12:30',
        amount: 'R\$ 45,80',
        type: 'expense',
        group: 'Trabalho',
      ),
      (
        id: 3,
        name: 'Compras no Mercado',
        category: 'Alimentação',
        location: 'Mercado',
        date: '06 nov, 18:00',
        amount: 'R\$ 312,90',
        type: 'expense',
        group: 'Família',
      ),
      (
        id: 4,
        name: 'Transferência PIX Recebida',
        category: 'Transferência',
        location: 'PIX',
        date: '05 nov, 09:10',
        amount: 'R\$ 180,00',
        type: 'income',
        group: 'Família',
      ),
      (
        id: 5,
        name: 'Cinema - Ingresso',
        category: 'Lazer',
        location: 'Cinema',
        date: '04 nov, 14:00',
        amount: 'R\$ 60,00',
        type: 'expense',
        group: 'Amigos',
      ),
    ];

    return Column(
      children: List.generate(
        recentTransactions.length,
        (index) {
          final transaction = recentTransactions[index];
          final isIncome = transaction.type == 'income';
          final color = index.isEven
              ? colorScheme.secondary.withValues(alpha: 0.7)
              : colorScheme.secondary.withValues(alpha: 0.4);

          return _TransactionListItem(
            id: transaction.id,
            name: transaction.name,
            category: transaction.category,
            location: transaction.location,
            date: transaction.date,
            amount: transaction.amount,
            isIncome: isIncome,
            group: transaction.group,
            color: color,
            textColor: colorScheme.onSecondary,
          );
        },
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final int id;
  final String name;
  final String category;
  final String location;
  final String date;
  final String amount;
  final bool isIncome;
  final String group;
  final Color color;
  final Color textColor;

  const _TransactionListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.group,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/transaction/$id');
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    size: 20,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 16,
                      color: isIncome ? Colors.green[700] : Colors.red[700],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        group,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'alimentação':
        return Icons.restaurant;
      case 'transporte':
        return Icons.directions_car;
      case 'lazer':
        return Icons.movie;
      case 'contas':
        return Icons.receipt_long;
      case 'trabalho':
        return Icons.work;
      case 'transferência':
        return Icons.compare_arrows;
      default:
        return Icons.shopping_cart;
    }
  }
}
