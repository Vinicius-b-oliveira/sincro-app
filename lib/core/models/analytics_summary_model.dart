import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_summary_model.freezed.dart';
part 'analytics_summary_model.g.dart';

@freezed
abstract class AnalyticsSummaryModel with _$AnalyticsSummaryModel {
  const factory AnalyticsSummaryModel({
    @JsonKey(name: 'chart_data') @Default([]) List<ChartDataModel> chartData,
    @JsonKey(name: 'summary_stats') required SummaryStatsModel summaryStats,
  }) = _AnalyticsSummaryModel;

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsSummaryModelFromJson(json);
}

@freezed
abstract class ChartDataModel with _$ChartDataModel {
  const factory ChartDataModel({
    required String category,
    required double total,
  }) = _ChartDataModel;

  factory ChartDataModel.fromJson(Map<String, dynamic> json) =>
      _$ChartDataModelFromJson(json);
}

@freezed
abstract class SummaryStatsModel with _$SummaryStatsModel {
  const factory SummaryStatsModel({
    @JsonKey(name: 'total_spent') required double totalSpent,
    @JsonKey(name: 'monthly_average') required double monthlyAverage,
    @JsonKey(name: 'max_spent') required double maxSpent,
    @JsonKey(name: 'min_spent') required double minSpent,
  }) = _SummaryStatsModel;

  factory SummaryStatsModel.fromJson(Map<String, dynamic> json) =>
      _$SummaryStatsModelFromJson(json);
}
