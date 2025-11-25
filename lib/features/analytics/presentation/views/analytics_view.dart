import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sincro/features/analytics/presentation/enums/analytics_enums.dart';
import 'package:sincro/features/analytics/presentation/viewmodels/analytics_viewmodel.dart';
import 'package:sincro/features/analytics/presentation/widgets/analytics_chart_section.dart';
import 'package:sincro/features/analytics/presentation/widgets/analytics_control_section.dart';
import 'package:sincro/features/analytics/presentation/widgets/analytics_summary_section.dart';

class AnalyticsView extends ConsumerWidget {
  final String? groupId;

  const AnalyticsView({this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = analyticsViewModelProvider(groupId);
    final state = ref.watch(provider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Análise de Gastos',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(provider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnalyticsControlSection(groupId: groupId),
                const SizedBox(height: 24),

                _buildDynamicTitle(context, state),
                const SizedBox(height: 16),

                AnalyticsChartSection(groupId: groupId),
                const SizedBox(height: 24),

                AnalyticsSummarySection(groupId: groupId),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicTitle(BuildContext context, dynamic state) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    String title = 'Gastos ';
    title += state.selectedViewMode == ViewMode.individual
        ? 'Individuais'
        : 'do Grupo';

    String period = '';
    switch (state.selectedTimePeriod) {
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
        if (state.customStartDate != null && state.customEndDate != null) {
          final fmt = DateFormat('dd/MM/yy');
          period =
              ' - ${fmt.format(state.customStartDate!)} a ${fmt.format(state.customEndDate!)}';
        } else {
          period = ' - Personalizado';
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
}
