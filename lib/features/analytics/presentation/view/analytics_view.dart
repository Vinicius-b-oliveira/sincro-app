import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum ChartType { bar, pie }

enum TimePeriod { threeMonths, sixMonths, oneYear, custom }

enum ViewMode { individual, group }

class AnalyticsView extends HookConsumerWidget {
  final String? groupId;

  const AnalyticsView({this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChartType = useState(ChartType.bar);
    final selectedTimePeriod = useState(TimePeriod.threeMonths);
    final selectedViewMode = useState(
      groupId != null ? ViewMode.group : ViewMode.individual,
    );
    final customStartDate = useState<DateTime?>(null);
    final customEndDate = useState<DateTime?>(null);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Análise de Gastos',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildControlSection(
                context,
                selectedChartType,
                selectedTimePeriod,
                selectedViewMode,
                customStartDate,
                customEndDate,
              ),
              const SizedBox(height: 24),

              _buildChartTitle(
                context,
                selectedViewMode,
                selectedTimePeriod,
                customStartDate,
                customEndDate,
              ),
              const SizedBox(height: 16),

              _buildChart(
                context,
                selectedChartType,
                selectedTimePeriod,
                selectedViewMode,
                customStartDate,
                customEndDate,
              ),
              const SizedBox(height: 24),

              _buildSummarySection(
                context,
                selectedTimePeriod,
                selectedViewMode,
                customStartDate,
                customEndDate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlSection(
    BuildContext context,
    ValueNotifier<ChartType> selectedChartType,
    ValueNotifier<TimePeriod> selectedTimePeriod,
    ValueNotifier<ViewMode> selectedViewMode,
    ValueNotifier<DateTime?> customStartDate,
    ValueNotifier<DateTime?> customEndDate,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visualização',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildModeChip(
              'Individual',
              selectedViewMode.value == ViewMode.individual,
              () => selectedViewMode.value = ViewMode.individual,
              colorScheme,
            ),
            const SizedBox(width: 8),
            if (groupId != null)
              _buildModeChip(
                'Grupo',
                selectedViewMode.value == ViewMode.group,
                () => selectedViewMode.value = ViewMode.group,
                colorScheme,
              ),
          ],
        ),
        const SizedBox(height: 16),

        Text(
          'Tipo de Gráfico',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildChartTypeChip(
              'Barras',
              Icons.bar_chart,
              selectedChartType.value == ChartType.bar,
              () => selectedChartType.value = ChartType.bar,
              colorScheme,
            ),
            _buildChartTypeChip(
              'Pizza',
              Icons.pie_chart,
              selectedChartType.value == ChartType.pie,
              () => selectedChartType.value = ChartType.pie,
              colorScheme,
            ),
          ],
        ),
        const SizedBox(height: 16),

        Text(
          'Período',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTimePeriodChip(
              '3 meses',
              selectedTimePeriod.value == TimePeriod.threeMonths,
              () => selectedTimePeriod.value = TimePeriod.threeMonths,
              colorScheme,
            ),
            _buildTimePeriodChip(
              '6 meses',
              selectedTimePeriod.value == TimePeriod.sixMonths,
              () => selectedTimePeriod.value = TimePeriod.sixMonths,
              colorScheme,
            ),
            _buildTimePeriodChip(
              '1 ano',
              selectedTimePeriod.value == TimePeriod.oneYear,
              () => selectedTimePeriod.value = TimePeriod.oneYear,
              colorScheme,
            ),
            _buildTimePeriodChip(
              'Personalizado',
              selectedTimePeriod.value == TimePeriod.custom,
              () => selectedTimePeriod.value = TimePeriod.custom,
              colorScheme,
            ),
          ],
        ),

        if (selectedTimePeriod.value == TimePeriod.custom) ...[
          const SizedBox(height: 16),
          _buildCustomDatePicker(
            context,
            customStartDate,
            customEndDate,
            colorScheme,
          ),
        ],
      ],
    );
  }

  Widget _buildModeChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChartTypeChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDatePicker(
    BuildContext context,
    ValueNotifier<DateTime?> startDate,
    ValueNotifier<DateTime?> endDate,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    startDate.value ??
                    DateTime.now().subtract(const Duration(days: 90)),
                firstDate: DateTime.now().subtract(
                  const Duration(days: 365 * 2),
                ),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                startDate.value = date;
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    startDate.value != null
                        ? '${startDate.value!.day}/${startDate.value!.month}/${startDate.value!.year}'
                        : 'Data inicial',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('até', style: TextStyle(color: colorScheme.onSurface)),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: endDate.value ?? DateTime.now(),
                firstDate:
                    startDate.value ??
                    DateTime.now().subtract(const Duration(days: 365 * 2)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                endDate.value = date;
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    endDate.value != null
                        ? '${endDate.value!.day}/${endDate.value!.month}/${endDate.value!.year}'
                        : 'Data final',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartTitle(
    BuildContext context,
    ValueNotifier<ViewMode> selectedViewMode,
    ValueNotifier<TimePeriod> selectedTimePeriod,
    ValueNotifier<DateTime?> customStartDate,
    ValueNotifier<DateTime?> customEndDate,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    String title = 'Gastos ';
    title += selectedViewMode.value == ViewMode.individual
        ? 'Individuais'
        : 'do Grupo';

    String period = '';
    switch (selectedTimePeriod.value) {
      case TimePeriod.threeMonths:
        period = ' - Últimos 3 meses';
        break;
      case TimePeriod.sixMonths:
        period = ' - Últimos 6 meses';
        break;
      case TimePeriod.oneYear:
        period = ' - Último ano';
        break;
      case TimePeriod.custom:
        if (customStartDate.value != null && customEndDate.value != null) {
          period =
              ' - ${customStartDate.value!.day}/${customStartDate.value!.month}/${customStartDate.value!.year} a ${customEndDate.value!.day}/${customEndDate.value!.month}/${customEndDate.value!.year}';
        } else {
          period = ' - Período personalizado';
        }
        break;
    }

    return Text(
      title + period,
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    ValueNotifier<ChartType> selectedChartType,
    ValueNotifier<TimePeriod> selectedTimePeriod,
    ValueNotifier<ViewMode> selectedViewMode,
    ValueNotifier<DateTime?> customStartDate,
    ValueNotifier<DateTime?> customEndDate,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final chartData = _getMockData(
      selectedTimePeriod.value,
      selectedViewMode.value,
    );

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: _buildChartWidget(selectedChartType.value, chartData, colorScheme),
    );
  }

  Widget _buildChartWidget(
    ChartType chartType,
    Map<String, double> data,
    ColorScheme colorScheme,
  ) {
    switch (chartType) {
      case ChartType.bar:
        return _buildBarChart(data, colorScheme);
      case ChartType.pie:
        return _buildPieChart(data, colorScheme);
    }
  }

  Widget _buildBarChart(Map<String, double> data, ColorScheme colorScheme) {
    final entries = data.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${entries[groupIndex].key}\nR\$ ${rod.toY.toStringAsFixed(2)}',
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
                if (value.toInt() >= 0 && value.toInt() < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      entries[value.toInt()].key,
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
        barGroups: List.generate(
          entries.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entries[index].value,
                color: _getCategoryColor(entries[index].key, colorScheme),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data, ColorScheme colorScheme) {
    final entries = data.entries.toList();
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sections: entries.asMap().entries.map((entry) {
                      final dataEntry = entry.value;
                      final percentage = (dataEntry.value / total * 100);

                      return PieChartSectionData(
                        color: _getCategoryColor(dataEntry.key, colorScheme),
                        value: dataEntry.value,
                        title: percentage > 5
                            ? '${percentage.toStringAsFixed(1)}%'
                            : '',
                        radius: 60,
                        titleStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        titlePositionPercentageOffset: 0.6,
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 25,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.map((entry) {
                    final percentage = (entry.value / total * 100);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(entry.key, colorScheme),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  entry.key,
                  colorScheme,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getCategoryColor(
                    entry.key,
                    colorScheme,
                  ).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key, colorScheme),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'R\$ ${entry.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    ValueNotifier<TimePeriod> selectedTimePeriod,
    ValueNotifier<ViewMode> selectedViewMode,
    ValueNotifier<DateTime?> customStartDate,
    ValueNotifier<DateTime?> customEndDate,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mockStats = _getMockStats(
      selectedTimePeriod.value,
      selectedViewMode.value,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo Estatístico',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Gasto',
                  mockStats['total']!,
                  Icons.trending_up,
                  Colors.red,
                  colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Média Mensal',
                  mockStats['average']!,
                  Icons.timeline,
                  colorScheme.primary,
                  colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Maior Gasto',
                  mockStats['max']!,
                  Icons.arrow_upward,
                  Colors.orange,
                  colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Menor Gasto',
                  mockStats['min']!,
                  Icons.arrow_downward,
                  Colors.green,
                  colorScheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getMockData(TimePeriod period, ViewMode viewMode) {
    if (viewMode == ViewMode.individual) {
      return {
        'Alimentação': 800.0,
        'Transporte': 300.0,
        'Lazer': 450.0,
        'Contas': 600.0,
        'Outros': 200.0,
      };
    } else {
      return {
        'Alimentação': 1200.0,
        'Transporte': 500.0,
        'Lazer': 650.0,
        'Contas': 800.0,
        'Outros': 300.0,
      };
    }
  }

  Map<String, String> _getMockStats(TimePeriod period, ViewMode viewMode) {
    if (viewMode == ViewMode.individual) {
      return {
        'total': 'R\$ 2.350,00',
        'average': 'R\$ 783,33',
        'max': 'R\$ 800,00',
        'min': 'R\$ 200,00',
      };
    } else {
      return {
        'total': 'R\$ 3.450,00',
        'average': 'R\$ 1.150,00',
        'max': 'R\$ 1.200,00',
        'min': 'R\$ 300,00',
      };
    }
  }

  Color _getCategoryColor(String category, ColorScheme colorScheme) {
    switch (category.toLowerCase()) {
      case 'alimentação':
        return Colors.orange;
      case 'transporte':
        return Colors.blue;
      case 'lazer':
        return Colors.purple;
      case 'contas':
        return Colors.red;
      case 'outros':
        return colorScheme.secondary;
      default:
        return colorScheme.primary;
    }
  }
}
