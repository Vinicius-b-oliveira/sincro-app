import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';
import 'package:sincro/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:sincro/features/analytics/data/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _dataSource;

  AnalyticsRepositoryImpl(this._dataSource);

  @override
  TaskEither<AppFailure, AnalyticsSummaryModel> getSummary({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    int? groupId,
    String? viewMode,
  }) {
    return _dataSource.getSummary(
      period: period,
      startDate: startDate,
      endDate: endDate,
      groupId: groupId,
      viewMode: viewMode,
    );
  }
}
