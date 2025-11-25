import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/features/analytics/presentation/enums/analytics_enums.dart';
import 'package:sincro/features/analytics/presentation/viewmodels/analytics_viewmodel.dart';

class AnalyticsControlSection extends ConsumerWidget {
  final String? groupId;

  const AnalyticsControlSection({
    this.groupId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = analyticsViewModelProvider(groupId);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groupId != null) ...[
          Text(
            'Visualização',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildModeChip(
                'Individual',
                state.selectedViewMode == ViewMode.individual,
                () => viewModel.setViewMode(ViewMode.individual),
                colorScheme,
              ),
              const SizedBox(width: 8),
              _buildModeChip(
                'Grupo',
                state.selectedViewMode == ViewMode.group,
                () => viewModel.setViewMode(ViewMode.group),
                colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

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
              state.selectedChartType == ChartType.bar,
              () => viewModel.setChartType(ChartType.bar),
              colorScheme,
            ),
            _buildChartTypeChip(
              'Pizza',
              Icons.pie_chart,
              state.selectedChartType == ChartType.pie,
              () => viewModel.setChartType(ChartType.pie),
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
              state.selectedTimePeriod == TimePeriod.threeMonths,
              () => viewModel.setTimePeriod(TimePeriod.threeMonths),
              colorScheme,
            ),
            _buildTimePeriodChip(
              '6 meses',
              state.selectedTimePeriod == TimePeriod.sixMonths,
              () => viewModel.setTimePeriod(TimePeriod.sixMonths),
              colorScheme,
            ),
            _buildTimePeriodChip(
              '1 ano',
              state.selectedTimePeriod == TimePeriod.oneYear,
              () => viewModel.setTimePeriod(TimePeriod.oneYear),
              colorScheme,
            ),
            _buildTimePeriodChip(
              'Personalizado',
              state.selectedTimePeriod == TimePeriod.custom,
              () => viewModel.setTimePeriod(TimePeriod.custom),
              colorScheme,
            ),
          ],
        ),

        if (state.selectedTimePeriod == TimePeriod.custom) ...[
          const SizedBox(height: 16),
          _buildCustomDatePicker(
            context,
            state.customStartDate,
            state.customEndDate,
            (start, end) => viewModel.setCustomDates(start, end),
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
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildChartTypeChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return FilterChip(
      label: Row(
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
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      showCheckmark: false,
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : colorScheme.outline.withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildTimePeriodChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : colorScheme.outline.withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildCustomDatePicker(
    BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
    Function(DateTime, DateTime) onDateSelected,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: (startDate != null && endDate != null)
                    ? DateTimeRange(start: startDate, end: endDate)
                    : null,
              );
              if (picked != null) {
                onDateSelected(picked.start, picked.end);
              }
            },
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              (startDate != null && endDate != null)
                  ? '${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month}'
                  : 'Selecionar Datas',
              style: const TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
