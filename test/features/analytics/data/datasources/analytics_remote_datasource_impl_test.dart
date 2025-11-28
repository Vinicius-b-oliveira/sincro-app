import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';
import 'package:sincro/features/analytics/data/datasources/analytics_remote_datasource_impl.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late AnalyticsRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = AnalyticsRemoteDataSourceImpl(mockDioClient);
  });

  group('AnalyticsRemoteDataSourceImpl', () {
    group('getSummary', () {
      final tSummaryJson = {
        'chart_data': [
          {'category': 'Alimentação', 'total': 500.0},
          {'category': 'Transporte', 'total': 300.0},
        ],
        'summary_stats': {
          'total_spent': 800.0,
          'monthly_average': 400.0,
          'max_spent': 500.0,
          'min_spent': 300.0,
        },
      };

      final tSummaryModel = AnalyticsSummaryModel(
        chartData: [
          const ChartDataModel(category: 'Alimentação', total: 500.0),
          const ChartDataModel(category: 'Transporte', total: 300.0),
        ],
        summaryStats: const SummaryStatsModel(
          totalSpent: 800.0,
          monthlyAverage: 400.0,
          maxSpent: 500.0,
          minSpent: 300.0,
        ),
      );

      test(
        'should return AnalyticsSummaryModel when called with period only',
        () async {
          // arrange
          when(
            mockDioClient.get(
              ApiRoutes.summary,
              queryParameters: {'period': 'month'},
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: tSummaryJson,
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiRoutes.summary),
              ),
            ),
          );

          // act
          final result = await dataSource.getSummary(period: 'month').run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) {
              expect(
                r.chartData.length,
                equals(tSummaryModel.chartData.length),
              );
              expect(
                r.summaryStats.totalSpent,
                equals(tSummaryModel.summaryStats.totalSpent),
              );
            },
          );
          verify(
            mockDioClient.get(
              ApiRoutes.summary,
              queryParameters: {'period': 'month'},
            ),
          ).called(1);
        },
      );

      test(
        'should return AnalyticsSummaryModel when called with date range',
        () async {
          // arrange
          final startDate = DateTime(2024, 1, 1);
          final endDate = DateTime(2024, 1, 31);

          when(
            mockDioClient.get(
              ApiRoutes.summary,
              queryParameters: {
                'start_date': '2024-01-01',
                'end_date': '2024-01-31',
              },
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: tSummaryJson,
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiRoutes.summary),
              ),
            ),
          );

          // act
          final result = await dataSource
              .getSummary(startDate: startDate, endDate: endDate)
              .run();

          // assert
          expect(result.isRight(), true);
          verify(
            mockDioClient.get(
              ApiRoutes.summary,
              queryParameters: {
                'start_date': '2024-01-01',
                'end_date': '2024-01-31',
              },
            ),
          ).called(1);
        },
      );

      test(
        'should return AnalyticsSummaryModel when called with groupId and viewMode',
        () async {
          // arrange
          when(
            mockDioClient.get(
              ApiRoutes.summary,
              queryParameters: {
                'period': 'month',
                'group_id': 1,
                'view_mode': 'personal',
              },
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: tSummaryJson,
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiRoutes.summary),
              ),
            ),
          );

          // act
          final result = await dataSource
              .getSummary(
                period: 'month',
                groupId: 1,
                viewMode: 'personal',
              )
              .run();

          // assert
          expect(result.isRight(), true);
          verify(
            mockDioClient.get(
              ApiRoutes.summary,
              queryParameters: {
                'period': 'month',
                'group_id': 1,
                'view_mode': 'personal',
              },
            ),
          ).called(1);
        },
      );

      test('should return AppFailure when api call fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Server error');

        when(
          mockDioClient.get(
            ApiRoutes.summary,
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource.getSummary(period: 'month').run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });

      test('should not include viewMode when groupId is null', () async {
        // arrange
        when(
          mockDioClient.get(
            ApiRoutes.summary,
            queryParameters: {'period': 'week'},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tSummaryJson,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.summary),
            ),
          ),
        );

        // act
        final result = await dataSource
            .getSummary(
              period: 'week',
              viewMode: 'personal',
            )
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.get(
            ApiRoutes.summary,
            queryParameters: {'period': 'week'},
          ),
        ).called(1);
      });
    });
  });
}
