import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/features/analytics/analytics_providers.dart';
import 'package:sincro/features/analytics/presentation/enums/analytics_enums.dart';
import 'package:sincro/features/analytics/presentation/viewmodels/analytics_state.dart';

part 'analytics_viewmodel.g.dart';

@riverpod
class AnalyticsViewModel extends _$AnalyticsViewModel {
  @override
  AnalyticsState build(String? groupId) {
    final initialMode = groupId != null ? ViewMode.group : ViewMode.individual;

    final initialState = AnalyticsState(
      groupId: groupId,
      selectedViewMode: initialMode,
    );

    Future.microtask(() => _fetchSummary(initialState));

    return initialState;
  }

  void setChartType(ChartType type) {
    state = state.copyWith(selectedChartType: type);
  }

  Future<void> setTimePeriod(TimePeriod period) async {
    state = state.copyWith(selectedTimePeriod: period);
    if (period != TimePeriod.custom) {
      await _fetchSummary(state);
    }
  }

  Future<void> setViewMode(ViewMode mode) async {
    state = state.copyWith(selectedViewMode: mode);
    await _fetchSummary(state);
  }

  Future<void> setCustomDates(DateTime start, DateTime end) async {
    state = state.copyWith(
      selectedTimePeriod: TimePeriod.custom,
      customStartDate: start,
      customEndDate: end,
    );
    await _fetchSummary(state);
  }

  Future<void> refresh() async {
    await _fetchSummary(state);
  }

  Future<void> _fetchSummary(AnalyticsState currentState) async {
    state = currentState.copyWith(summary: const AsyncValue.loading());

    final repository = ref.read(analyticsRepositoryProvider);

    String? periodParam;
    DateTime? startParam;
    DateTime? endParam;

    if (currentState.selectedTimePeriod != TimePeriod.custom) {
      periodParam = _mapPeriodToString(currentState.selectedTimePeriod);
    } else {
      if (currentState.customStartDate != null &&
          currentState.customEndDate != null) {
        startParam = currentState.customStartDate;
        endParam = currentState.customEndDate;
      } else {
        return;
      }
    }

    final result = await repository
        .getSummary(
          period: periodParam,
          startDate: startParam,
          endDate: endParam,
          groupId: currentState.groupId != null
              ? int.tryParse(currentState.groupId!)
              : null,
          viewMode: currentState.selectedViewMode.name,
        )
        .run();

    result.fold(
      (failure) {
        state = currentState.copyWith(
          summary: AsyncValue.error(failure, StackTrace.current),
        );
      },
      (data) {
        state = currentState.copyWith(summary: AsyncValue.data(data));
      },
    );
  }

  String _mapPeriodToString(TimePeriod period) {
    switch (period) {
      case TimePeriod.threeMonths:
        return '3m';
      case TimePeriod.sixMonths:
        return '6m';
      case TimePeriod.oneYear:
        return '1y';
      default:
        return '3m';
    }
  }
}
