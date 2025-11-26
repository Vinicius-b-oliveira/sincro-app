import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';
import 'package:sincro/core/network/dio_client.dart';
import 'package:sincro/features/analytics/data/datasources/analytics_remote_datasource.dart';

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final DioClient _client;

  AnalyticsRemoteDataSourceImpl(this._client);

  @override
  TaskEither<AppFailure, AnalyticsSummaryModel> getSummary({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    int? groupId,
    String? viewMode,
  }) {
    final queryParams = <String, dynamic>{};

    if (period != null) {
      queryParams['period'] = period;
    } else if (startDate != null && endDate != null) {
      final dateFormat = DateFormat('yyyy-MM-dd');
      queryParams['start_date'] = dateFormat.format(startDate);
      queryParams['end_date'] = dateFormat.format(endDate);
    }

    if (groupId != null) {
      queryParams['group_id'] = groupId;
      if (viewMode != null) {
        queryParams['view_mode'] = viewMode;
      }
    }

    return _client.get(ApiRoutes.summary, queryParameters: queryParams).map((
      response,
    ) {
      return AnalyticsSummaryModel.fromJson(response.data);
    });
  }
}
