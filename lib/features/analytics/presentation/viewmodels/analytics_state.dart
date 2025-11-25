import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';
import 'package:sincro/features/analytics/presentation/enums/analytics_enums.dart';

part 'analytics_state.freezed.dart';

@freezed
abstract class AnalyticsState with _$AnalyticsState {
  const factory AnalyticsState({
    @Default(AsyncValue.loading()) AsyncValue<AnalyticsSummaryModel> summary,

    @Default(TimePeriod.threeMonths) TimePeriod selectedTimePeriod,
    @Default(ChartType.bar) ChartType selectedChartType,
    @Default(ViewMode.individual) ViewMode selectedViewMode,

    DateTime? customStartDate,
    DateTime? customEndDate,

    String? groupId,
  }) = _AnalyticsState;
}
