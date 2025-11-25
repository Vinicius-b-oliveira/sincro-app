import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';

abstract class AnalyticsRemoteDataSource {
  TaskEither<AppFailure, AnalyticsSummaryModel> getSummary({
    String? period,

    DateTime? startDate,
    DateTime? endDate,

    int? groupId,
    String? viewMode,
  });
}
