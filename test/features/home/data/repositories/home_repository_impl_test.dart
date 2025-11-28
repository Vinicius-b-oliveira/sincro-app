import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/balance_model.dart';
import 'package:sincro/features/home/data/repositories/home_repository_impl.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late HomeRepositoryImpl repository;
  late MockHomeRemoteDataSource mockDataSource;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockDataSource = MockHomeRemoteDataSource();
    repository = HomeRepositoryImpl(mockDataSource);
  });

  group('HomeRepositoryImpl', () {
    group('getBalance', () {
      final tBalanceModel = const BalanceModel(
        totalBalance: 1500.0,
        periodIncome: 2000.0,
        periodExpenses: 500.0,
      );

      test('should delegate call to datasource without groupId', () async {
        // arrange
        when(
          mockDataSource.getBalance(groupId: null),
        ).thenReturn(TaskEither.right(tBalanceModel));

        // act
        final result = await repository.getBalance().run();

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
        verify(mockDataSource.getBalance(groupId: null)).called(1);
      });

      test('should delegate call to datasource with groupId', () async {
        // arrange
        when(
          mockDataSource.getBalance(groupId: 1),
        ).thenReturn(TaskEither.right(tBalanceModel));

        // act
        final result = await repository.getBalance(groupId: 1).run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) => expect(r.totalBalance, equals(tBalanceModel.totalBalance)),
        );
        verify(mockDataSource.getBalance(groupId: 1)).called(1);
      });

      test('should return failure when datasource fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Server error');

        when(
          mockDataSource.getBalance(groupId: anyNamed('groupId')),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.getBalance().run();

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
