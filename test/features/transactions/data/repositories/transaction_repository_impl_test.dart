import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/features/transactions/data/repositories/transaction_repository_impl.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late TransactionRepositoryImpl repository;
  late MockTransactionRemoteDataSource mockDataSource;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockDataSource = MockTransactionRemoteDataSource();
    repository = TransactionRepositoryImpl(mockDataSource);
  });

  group('TransactionRepositoryImpl', () {
    final tDate = DateTime(2024, 1, 15);
    final tCreatedAt = DateTime(2024, 1, 15, 10, 30);

    final tTransactionModel = TransactionModel(
      id: 1,
      title: 'Test Transaction',
      amount: 100.0,
      type: TransactionType.expense,
      category: 'Food',
      date: tDate,
      createdAt: tCreatedAt,
      userId: 1,
      userName: 'Test User',
    );

    final tMetaData = const MetaData(
      currentPage: 1,
      lastPage: 1,
      perPage: 15,
      total: 1,
    );

    final tPaginatedResponse = PaginatedResponse<TransactionModel>(
      data: [tTransactionModel],
      meta: tMetaData,
    );

    group('getTransactions', () {
      test('should delegate call to datasource with all parameters', () async {
        // arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);

        when(
          mockDataSource.getTransactions(
            page: 1,
            search: 'groceries',
            type: TransactionType.expense,
            startDate: startDate,
            endDate: endDate,
            groupIds: [1, 2],
            categories: ['Food'],
          ),
        ).thenReturn(TaskEither.right(tPaginatedResponse));

        // act
        final result = await repository
            .getTransactions(
              page: 1,
              search: 'groceries',
              type: TransactionType.expense,
              startDate: startDate,
              endDate: endDate,
              groupIds: [1, 2],
              categories: ['Food'],
            )
            .run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.data.length, equals(1));
            expect(r.data.first.title, equals(tTransactionModel.title));
          },
        );
        verify(
          mockDataSource.getTransactions(
            page: 1,
            search: 'groceries',
            type: TransactionType.expense,
            startDate: startDate,
            endDate: endDate,
            groupIds: [1, 2],
            categories: ['Food'],
          ),
        ).called(1);
      });

      test('should delegate call to datasource with page only', () async {
        // arrange
        when(
          mockDataSource.getTransactions(
            page: 1,
            search: null,
            type: null,
            startDate: null,
            endDate: null,
            groupIds: null,
            categories: null,
          ),
        ).thenReturn(TaskEither.right(tPaginatedResponse));

        // act
        final result = await repository.getTransactions(page: 1).run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDataSource.getTransactions(
            page: 1,
            search: null,
            type: null,
            startDate: null,
            endDate: null,
            groupIds: null,
            categories: null,
          ),
        ).called(1);
      });

      test('should return failure when datasource fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Server error');

        when(
          mockDataSource.getTransactions(
            page: anyNamed('page'),
            search: anyNamed('search'),
            type: anyNamed('type'),
            startDate: anyNamed('startDate'),
            endDate: anyNamed('endDate'),
            groupIds: anyNamed('groupIds'),
            categories: anyNamed('categories'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.getTransactions(page: 1).run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });
    });

    group('createTransaction', () {
      test('should delegate call to datasource with all parameters', () async {
        // arrange
        when(
          mockDataSource.createTransaction(
            title: 'Test Transaction',
            amount: 100.0,
            type: TransactionType.expense,
            date: tDate,
            category: 'Food',
            description: 'Test description',
            groupId: 1,
          ),
        ).thenReturn(TaskEither.right(tTransactionModel));

        // act
        final result = await repository
            .createTransaction(
              title: 'Test Transaction',
              amount: 100.0,
              type: TransactionType.expense,
              date: tDate,
              category: 'Food',
              description: 'Test description',
              groupId: 1,
            )
            .run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.title, equals(tTransactionModel.title));
            expect(r.amount, equals(tTransactionModel.amount));
          },
        );
        verify(
          mockDataSource.createTransaction(
            title: 'Test Transaction',
            amount: 100.0,
            type: TransactionType.expense,
            date: tDate,
            category: 'Food',
            description: 'Test description',
            groupId: 1,
          ),
        ).called(1);
      });

      test(
        'should delegate call to datasource with required parameters only',
        () async {
          // arrange
          when(
            mockDataSource.createTransaction(
              title: 'Test Transaction',
              amount: 100.0,
              type: TransactionType.expense,
              date: tDate,
              category: 'Food',
              description: null,
              groupId: null,
            ),
          ).thenReturn(TaskEither.right(tTransactionModel));

          // act
          final result = await repository
              .createTransaction(
                title: 'Test Transaction',
                amount: 100.0,
                type: TransactionType.expense,
                date: tDate,
                category: 'Food',
              )
              .run();

          // assert
          expect(result.isRight(), true);
        },
      );

      test('should return failure when datasource fails', () async {
        // arrange
        final tFailure = ValidationFailure(
          message: 'Validation error',
          errors: {
            'title': ['Title is required'],
          },
        );

        when(
          mockDataSource.createTransaction(
            title: anyNamed('title'),
            amount: anyNamed('amount'),
            type: anyNamed('type'),
            date: anyNamed('date'),
            category: anyNamed('category'),
            description: anyNamed('description'),
            groupId: anyNamed('groupId'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository
            .createTransaction(
              title: 'Test Transaction',
              amount: 100.0,
              type: TransactionType.expense,
              date: tDate,
              category: 'Food',
            )
            .run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<ValidationFailure>()),
          (r) => fail('Should be left'),
        );
      });
    });

    group('updateTransaction', () {
      test('should delegate call to datasource with all parameters', () async {
        // arrange
        final updateDate = DateTime(2024, 2, 1);

        when(
          mockDataSource.updateTransaction(
            id: 1,
            title: 'Updated Title',
            amount: 200.0,
            type: TransactionType.income,
            date: updateDate,
            category: 'Salary',
            description: 'Updated description',
            groupId: 2,
          ),
        ).thenReturn(TaskEither.right(tTransactionModel));

        // act
        final result = await repository
            .updateTransaction(
              id: 1,
              title: 'Updated Title',
              amount: 200.0,
              type: TransactionType.income,
              date: updateDate,
              category: 'Salary',
              description: 'Updated description',
              groupId: 2,
            )
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDataSource.updateTransaction(
            id: 1,
            title: 'Updated Title',
            amount: 200.0,
            type: TransactionType.income,
            date: updateDate,
            category: 'Salary',
            description: 'Updated description',
            groupId: 2,
          ),
        ).called(1);
      });

      test(
        'should delegate call to datasource with partial parameters',
        () async {
          // arrange
          when(
            mockDataSource.updateTransaction(
              id: 1,
              title: 'Updated Title',
              amount: null,
              type: null,
              date: null,
              category: null,
              description: null,
              groupId: null,
            ),
          ).thenReturn(TaskEither.right(tTransactionModel));

          // act
          final result = await repository
              .updateTransaction(
                id: 1,
                title: 'Updated Title',
              )
              .run();

          // assert
          expect(result.isRight(), true);
        },
      );

      test('should return failure when datasource fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Update failed');

        when(
          mockDataSource.updateTransaction(
            id: anyNamed('id'),
            title: anyNamed('title'),
            amount: anyNamed('amount'),
            type: anyNamed('type'),
            date: anyNamed('date'),
            category: anyNamed('category'),
            description: anyNamed('description'),
            groupId: anyNamed('groupId'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository
            .updateTransaction(
              id: 1,
              title: 'Updated Title',
            )
            .run();

        // assert
        expect(result.isLeft(), true);
      });
    });

    group('deleteTransaction', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.deleteTransaction(1),
        ).thenReturn(TaskEither.right(null));

        // act
        final result = await repository.deleteTransaction(1).run();

        // assert
        expect(result.isRight(), true);
        verify(mockDataSource.deleteTransaction(1)).called(1);
      });

      test('should return failure when datasource fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Deletion failed');

        when(
          mockDataSource.deleteTransaction(1),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.deleteTransaction(1).run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });
    });

    group('getTransaction', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.getTransaction(1),
        ).thenReturn(TaskEither.right(tTransactionModel));

        // act
        final result = await repository.getTransaction(1).run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.id, equals(tTransactionModel.id));
            expect(r.title, equals(tTransactionModel.title));
          },
        );
        verify(mockDataSource.getTransaction(1)).called(1);
      });

      test('should return failure when datasource fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Not found');

        when(
          mockDataSource.getTransaction(1),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.getTransaction(1).run();

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
