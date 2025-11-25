import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';
import 'package:sincro/features/analytics/presentation/enums/analytics_enums.dart';
import 'package:sincro/features/analytics/presentation/viewmodels/analytics_viewmodel.dart';

class AnalyticsChartSection extends ConsumerWidget {
  final String? groupId;

  const AnalyticsChartSection({this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = analyticsViewModelProvider(groupId);
    final state = ref.watch(provider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return state.summary.when(
      loading: () => const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => SizedBox(
        height: 400,
        child: Center(child: Text('Erro ao carregar gráfico: $err')),
      ),
      data: (summaryModel) {
        if (summaryModel.chartData.isEmpty) {
          return Container(
            height: 400,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 48, color: colorScheme.outline),
                const SizedBox(height: 8),
                const Text('Sem dados para exibir'),
              ],
            ),
          );
        }

        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: state.selectedChartType == ChartType.bar
              ? _buildBarChart(summaryModel.chartData, colorScheme)
              : _buildPieChart(summaryModel.chartData, colorScheme),
        );
      },
    );
  }

  Widget _buildBarChart(List<ChartDataModel> data, ColorScheme colorScheme) {
    final sortedData = List<ChartDataModel>.from(data)
      ..sort((a, b) => b.total.compareTo(a.total));

    final displayData = sortedData.take(6).toList();

    final maxY =
        displayData.map((e) => e.total).reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = displayData[groupIndex];
              return BarTooltipItem(
                '${item.category}\n${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.total)}',
                TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
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
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < displayData.length) {
                  final category = displayData[value.toInt()].category;
                  final label = category.length > 8
                      ? '${category.substring(0, 6)}..'
                      : category;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurface,
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
        barGroups: List.generate(displayData.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: displayData[index].total,
                color: _getCategoryColor(
                  displayData[index].category,
                  colorScheme,
                ),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPieChart(List<ChartDataModel> data, ColorScheme colorScheme) {
    final total = data.fold<double>(0, (sum, item) => sum + item.total);

    final sortedData = List<ChartDataModel>.from(data)
      ..sort((a, b) => b.total.compareTo(a.total));

    List<ChartDataModel> displayData = sortedData;
    if (sortedData.length > 5) {
      final top4 = sortedData.take(4).toList();
      final othersTotal = sortedData
          .skip(4)
          .fold<double>(0, (s, i) => s + i.total);
      displayData = [
        ...top4,
        ChartDataModel(category: 'Outros', total: othersTotal),
      ];
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: displayData.map((item) {
                final percentage = (item.total / total * 100);
                final isLarge = percentage > 10;
                return PieChartSectionData(
                  color: _getCategoryColor(item.category, colorScheme),
                  value: item.total,
                  title: isLarge ? '${percentage.toStringAsFixed(0)}%' : '',
                  radius: isLarge ? 60 : 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: displayData.map((item) {
              final percentage = (item.total / total * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(item.category, colorScheme),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.category} (${percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category, ColorScheme colorScheme) {
    final cat = category.toLowerCase();
    if (cat.contains('aliment')) return Colors.orange;
    if (cat.contains('transporte')) return Colors.blue;
    if (cat.contains('lazer')) return Colors.purple;
    if (cat.contains('contas')) return Colors.red;
    if (cat.contains('moradia')) return Colors.brown;
    if (cat.contains('saúde')) return Colors.teal;
    if (cat.contains('educa')) return Colors.indigo;
    if (cat.contains('invest')) return Colors.green;
    return colorScheme.secondary;
  }
}
