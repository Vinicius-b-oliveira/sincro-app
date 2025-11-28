import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/features/transactions/data/datasources/transaction_remote_datasource_impl.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late TransactionRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = TransactionRemoteDataSourceImpl(mockDioClient);
  });

  group('TransactionRemoteDataSourceImpl', () {
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

    final tTransactionJson = {
      'id': 1,
      'title': 'Test Transaction',
      'amount': 100.0,
      'type': 'expense',
      'category': 'Food',
      'transaction_date': '2024-01-15T00:00:00.000Z',
      'created_at': '2024-01-15T10:30:00.000Z',
      'user_id': 1,
      'user_name': 'Test User',
    };

    final tPaginatedResponse = {
      'data': [tTransactionJson],
      'meta': {
        'current_page': 1,
        'last_page': 1,
        'per_page': 15,
        'total': 1,
      },
    };

    group('getTransactions', () {
      test(
        'should return PaginatedResponse when successful with page only',
        () async {
          // arrange
          when(
            mockDioClient.get(
              ApiRoutes.transactions,
              queryParameters: {'page': 1},
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: tPaginatedResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiRoutes.transactions),
              ),
            ),
          );

          // act
          final result = await dataSource.getTransactions(page: 1).run();

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
            mockDioClient.get(
              ApiRoutes.transactions,
              queryParameters: {'page': 1},
            ),
          ).called(1);
        },
      );

      test('should include search when provided', () async {
        // arrange
        when(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: {'page': 1, 'search': 'groceries'},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tPaginatedResponse,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.transactions),
            ),
          ),
        );

        // act
        final result = await dataSource
            .getTransactions(page: 1, search: 'groceries')
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: {'page': 1, 'search': 'groceries'},
          ),
        ).called(1);
      });

      test('should include type when provided', () async {
        // arrange
        when(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: {'page': 1, 'type': 'expense'},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tPaginatedResponse,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.transactions),
            ),
          ),
        );

        // act
        final result = await dataSource
            .getTransactions(page: 1, type: TransactionType.expense)
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: {'page': 1, 'type': 'expense'},
          ),
        ).called(1);
      });

      test('should include date range when provided', () async {
        // arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);

        when(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: {
              'page': 1,
              'date_start': '2024-01-01',
              'date_end': '2024-01-31',
            },
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tPaginatedResponse,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.transactions),
            ),
          ),
        );

        // act
        final result = await dataSource
            .getTransactions(
              page: 1,
              startDate: startDate,
              endDate: endDate,
            )
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: {
              'page': 1,
              'date_start': '2024-01-01',
              'date_end': '2024-01-31',
            },
          ),
        ).called(1);
      });

      test('should include groupIds when provided', () async {
        // arrange
        when(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: {
              'page': 1,
              'group_id[]': [1, 2],
            },
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tPaginatedResponse,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.transactions),
            ),
          ),
        );

        // act
        final result = await dataSource
            .getTransactions(page: 1, groupIds: [1, 2])
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: {
              'page': 1,
              'group_id[]': [1, 2],
            },
          ),
        ).called(1);
      });

      test('should include categories when provided', () async {
        // arrange
        when(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: {
              'page': 1,
              'category[]': ['Food', 'Transport'],
            },
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tPaginatedResponse,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.transactions),
            ),
          ),
        );

        // act
        final result = await dataSource
            .getTransactions(page: 1, categories: ['Food', 'Transport'])
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: {
              'page': 1,
              'category[]': ['Food', 'Transport'],
            },
          ),
        ).called(1);
      });

      test('should return failure when api call fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Server error');

        when(
          mockDioClient.get(
            ApiRoutes.transactions,
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource.getTransactions(page: 1).run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });
    });

    group('createTransaction', () {
      test(
        'should return TransactionModel when creation is successful',
        () async {
          // arrange
          when(
            mockDioClient.post(
              ApiRoutes.transactions,
              data: {
                'title': 'Test Transaction',
                'amount': 100.0,
                'type': 'expense',
                'transaction_date': '2024-01-15',
                'category': 'Food',
              },
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: tTransactionJson,
                statusCode: 201,
                requestOptions: RequestOptions(path: ApiRoutes.transactions),
              ),
            ),
          );

          // act
          final result = await dataSource
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
          result.fold(
            (l) => fail('Should be right'),
            (r) {
              expect(r.title, equals(tTransactionModel.title));
              expect(r.amount, equals(tTransactionModel.amount));
            },
          );
        },
      );

      test('should include optional parameters when provided', () async {
        // arrange
        when(
          mockDioClient.post(
            ApiRoutes.transactions,
            data: {
              'title': 'Test Transaction',
              'amount': 100.0,
              'type': 'expense',
              'transaction_date': '2024-01-15',
              'category': 'Food',
              'description': 'Test description',
              'group_id': 1,
            },
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tTransactionJson,
              statusCode: 201,
              requestOptions: RequestOptions(path: ApiRoutes.transactions),
            ),
          ),
        );

        // act
        final result = await dataSource
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
        verify(
          mockDioClient.post(
            ApiRoutes.transactions,
            data: {
              'title': 'Test Transaction',
              'amount': 100.0,
              'type': 'expense',
              'transaction_date': '2024-01-15',
              'category': 'Food',
              'description': 'Test description',
              'group_id': 1,
            },
          ),
        ).called(1);
      });

      test('should return failure when creation fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Creation failed');

        when(
          mockDioClient.post(
            ApiRoutes.transactions,
            data: anyNamed('data'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource
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
      });
    });

    group('updateTransaction', () {
      test(
        'should return TransactionModel when update is successful',
        () async {
          // arrange
          when(
            mockDioClient.put(
              ApiRoutes.transactionById(1),
              data: {'title': 'Updated Title'},
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: {...tTransactionJson, 'title': 'Updated Title'},
                statusCode: 200,
                requestOptions: RequestOptions(
                  path: ApiRoutes.transactionById(1),
                ),
              ),
            ),
          );

          // act
          final result = await dataSource
              .updateTransaction(
                id: 1,
                title: 'Updated Title',
              )
              .run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) => expect(r.title, equals('Updated Title')),
          );
        },
      );

      test('should include all optional parameters when provided', () async {
        // arrange
        final updateDate = DateTime(2024, 2, 1);

        when(
          mockDioClient.put(
            ApiRoutes.transactionById(1),
            data: {
              'title': 'Updated Title',
              'amount': 200.0,
              'type': 'income',
              'transaction_date': '2024-02-01',
              'category': 'Salary',
              'description': 'Updated description',
              'group_id': 2,
            },
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tTransactionJson,
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.transactionById(1),
              ),
            ),
          ),
        );

        // act
        final result = await dataSource
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
          mockDioClient.put(
            ApiRoutes.transactionById(1),
            data: {
              'title': 'Updated Title',
              'amount': 200.0,
              'type': 'income',
              'transaction_date': '2024-02-01',
              'category': 'Salary',
              'description': 'Updated description',
              'group_id': 2,
            },
          ),
        ).called(1);
      });

      test('should return failure when update fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Update failed');

        when(
          mockDioClient.put(
            ApiRoutes.transactionById(1),
            data: anyNamed('data'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource
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
      test('should return void when deletion is successful', () async {
        // arrange
        when(
          mockDioClient.delete(ApiRoutes.transactionById(1)),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.transactionById(1),
              ),
            ),
          ),
        );

        // act
        final result = await dataSource.deleteTransaction(1).run();

        // assert
        expect(result.isRight(), true);
        verify(mockDioClient.delete(ApiRoutes.transactionById(1))).called(1);
      });

      test('should return failure when deletion fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Deletion failed');

        when(
          mockDioClient.delete(ApiRoutes.transactionById(1)),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource.deleteTransaction(1).run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });
    });

    group('getTransaction', () {
      test('should return TransactionModel when successful', () async {
        // arrange
        when(
          mockDioClient.get(ApiRoutes.transactionById(1)),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tTransactionJson,
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.transactionById(1),
              ),
            ),
          ),
        );

        // act
        final result = await dataSource.getTransaction(1).run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.id, equals(tTransactionModel.id));
            expect(r.title, equals(tTransactionModel.title));
          },
        );
        verify(mockDioClient.get(ApiRoutes.transactionById(1))).called(1);
      });

      test('should return failure when api call fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Not found');

        when(
          mockDioClient.get(ApiRoutes.transactionById(1)),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource.getTransaction(1).run();

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
