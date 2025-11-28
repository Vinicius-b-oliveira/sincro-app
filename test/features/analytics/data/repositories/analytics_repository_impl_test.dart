import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';
import 'package:sincro/features/analytics/data/repositories/analytics_repository_impl.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late AnalyticsRepositoryImpl repository;
  late MockAnalyticsRemoteDataSource mockDataSource;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockDataSource = MockAnalyticsRemoteDataSource();
    repository = AnalyticsRepositoryImpl(mockDataSource);
  });

  group('AnalyticsRepositoryImpl', () {
    group('getSummary', () {
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

      test('should delegate call to datasource with all parameters', () async {
        // arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);

        when(
          mockDataSource.getSummary(
            period: 'month',
            startDate: startDate,
            endDate: endDate,
            groupId: 1,
            viewMode: 'personal',
          ),
        ).thenReturn(TaskEither.right(tSummaryModel));

        // act
        final result = await repository
            .getSummary(
              period: 'month',
              startDate: startDate,
              endDate: endDate,
              groupId: 1,
              viewMode: 'personal',
            )
            .run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) => expect(r, equals(tSummaryModel)),
        );
        verify(
          mockDataSource.getSummary(
            period: 'month',
            startDate: startDate,
            endDate: endDate,
            groupId: 1,
            viewMode: 'personal',
          ),
        ).called(1);
      });

      test('should delegate call to datasource with only period', () async {
        // arrange
        when(
          mockDataSource.getSummary(
            period: 'week',
            startDate: null,
            endDate: null,
            groupId: null,
            viewMode: null,
          ),
        ).thenReturn(TaskEither.right(tSummaryModel));

        // act
        final result = await repository.getSummary(period: 'week').run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDataSource.getSummary(
            period: 'week',
            startDate: null,
            endDate: null,
            groupId: null,
            viewMode: null,
          ),
        ).called(1);
      });

      test('should return failure when datasource fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Server error');

        when(
          mockDataSource.getSummary(
            period: anyNamed('period'),
            startDate: anyNamed('startDate'),
            endDate: anyNamed('endDate'),
            groupId: anyNamed('groupId'),
            viewMode: anyNamed('viewMode'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.getSummary(period: 'month').run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });
    });
  });
}
