import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/routing/app_routes.dart'; // Substitua 'sincro'

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hook para controlar a visibilidade do saldo
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
              // --- Seção Saldo ---
              _buildBalanceSection(
                context,
                textTheme,
                colorScheme,
                isBalanceVisible,
              ),
              const SizedBox(height: 24),

              // --- Seção Gráfico ---
              _buildChartSection(context, colorScheme),
              const SizedBox(height: 24),

              // --- Botão Adicionar Gasto ---
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.addTransaction),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Adicionar novo gasto',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Seção Histórico Recente ---
              _buildRecentHistory(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // Seção Saldo
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
          child: Text(isBalanceVisible.value ? 'Ocultar' : 'Mostrar'),
          style: TextButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // Seção do Gráfico de Barras
  Widget _buildChartSection(BuildContext context, ColorScheme colorScheme) {
    // Dados mocados para o gráfico e a legenda
    final chartData = [
      (label: 'contas', value: 500.0, color: colorScheme.secondary),
      (label: 'comida', value: 800.0, color: colorScheme.primary),
      (label: 'lazer', value: 300.0, color: colorScheme.secondary),
      (label: 'transporte', value: 600.0, color: colorScheme.primary),
      (label: 'outros', value: 450.0, color: colorScheme.secondary),
      (label: 'invest', value: 900.0, color: colorScheme.primary),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O Gráfico
        Expanded(
          flex: 2,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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
        // A Legenda
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

  // Seção de Histórico Recente
  Widget _buildRecentHistory(BuildContext context, ColorScheme colorScheme) {
    // Dados mocados para a lista
    final recentTransactions = [
      (date: '24 out, 20:15', place: 'Uber', amount: '24,50'),
      (date: '24 out, 12:30', place: 'Restaurante', amount: '45,80'),
      (date: '23 out, 18:00', place: 'Mercado', amount: '312,90'),
      (date: '22 out, 09:10', place: 'Padaria', amount: '18,00'),
      (date: '21 out, 14:00', place: 'Cinema', amount: '60,00'),
    ];

    return Column(
      children: List.generate(
        recentTransactions.length,
        (index) {
          final item = recentTransactions[index];
          // Cor alternada
          final color = index.isEven
              ? colorScheme.secondary.withOpacity(0.7)
              : colorScheme.secondary.withOpacity(0.4);

          return _TransactionListItem(
            date: item.date,
            place: item.place,
            amount: item.amount,
            color: color,
            textColor: colorScheme.onSecondaryContainer,
          );
        },
      ),
    );
  }
}

// Widget auxiliar para o item da lista
class _TransactionListItem extends StatelessWidget {
  final String date;
  final String place;
  final String amount;
  final Color color;
  final Color textColor;

  const _TransactionListItem({
    required this.date,
    required this.place,
    required this.amount,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
          Text(
            'R\$ $amount',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
