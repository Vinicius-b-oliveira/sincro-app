import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/balance_model.dart';
import 'package:sincro/features/home/data/datasources/home_remote_datasource_impl.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late HomeRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = HomeRemoteDataSourceImpl(mockDioClient);
  });

  group('HomeRemoteDataSourceImpl', () {
    group('getBalance', () {
      final tBalanceJson = {
        'total_balance': '1500.00',
        'period_income': '2000.00',
        'period_expenses': '500.00',
      };

      final tBalanceModel = const BalanceModel(
        totalBalance: 1500.0,
        periodIncome: 2000.0,
        periodExpenses: 500.0,
      );

      test(
        'should return BalanceModel when successful without groupId',
        () async {
          // arrange
          when(
            mockDioClient.get(
              ApiRoutes.balance,
              queryParameters: {},
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: tBalanceJson,
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiRoutes.balance),
              ),
            ),
          );

          // act
          final result = await dataSource.getBalance().run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) {
              expect(r.totalBalance, equals(tBalanceModel.totalBalance));
              expect(r.periodIncome, equals(tBalanceModel.periodIncome));
              expect(r.periodExpenses, equals(tBalanceModel.periodExpenses));
            },
          );
          verify(
            mockDioClient.get(
              ApiRoutes.balance,
              queryParameters: {},
            ),
          ).called(1);
        },
      );

      test('should return BalanceModel when successful with groupId', () async {
        // arrange
        when(
          mockDioClient.get(
            ApiRoutes.balance,
            queryParameters: {'group_id': 1},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tBalanceJson,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.balance),
            ),
          ),
        );

        // act
        final result = await dataSource.getBalance(groupId: 1).run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) => expect(r.totalBalance, equals(tBalanceModel.totalBalance)),
        );
        verify(
          mockDioClient.get(
            ApiRoutes.balance,
            queryParameters: {'group_id': 1},
          ),
        ).called(1);
      });

      test('should return failure when api call fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Server error');

        when(
          mockDioClient.get(
            ApiRoutes.balance,
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource.getBalance().run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });

      test('should handle numeric values in response', () async {
        // arrange
        final tNumericBalanceJson = {
          'total_balance': 1500.0,
          'period_income': 2000.0,
          'period_expenses': 500.0,
        };

        when(
          mockDioClient.get(
            ApiRoutes.balance,
            queryParameters: {},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tNumericBalanceJson,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.balance),
            ),
          ),
        );

        // act
        final result = await dataSource.getBalance().run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.totalBalance, equals(1500.0));
            expect(r.periodIncome, equals(2000.0));
            expect(r.periodExpenses, equals(500.0));
          },
        );
      });
    });
  });
}
