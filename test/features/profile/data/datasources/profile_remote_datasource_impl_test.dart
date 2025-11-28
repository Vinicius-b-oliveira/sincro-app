import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/features/profile/data/datasources/profile_remote_datasource_impl.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late ProfileRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = ProfileRemoteDataSourceImpl(mockDioClient);
  });

  group('ProfileRemoteDataSourceImpl', () {
    const tUserModel = UserModel(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
    );

    final tUserJson = {
      'id': 1,
      'name': 'Test User',
      'email': 'test@example.com',
    };

    group('updateProfile', () {
      test('should return UserModel when update is successful', () async {
        // arrange
        when(
          mockDioClient.patch(
            ApiRoutes.userProfile,
            data: {'name': 'Updated Name'},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {...tUserJson, 'name': 'Updated Name'},
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.userProfile),
            ),
          ),
        );

        // act
        final result = await dataSource
            .updateProfile(name: 'Updated Name')
            .run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.name, equals('Updated Name'));
            expect(r.email, equals(tUserModel.email));
          },
        );
        verify(
          mockDioClient.patch(
            ApiRoutes.userProfile,
            data: {'name': 'Updated Name'},
          ),
        ).called(1);
      });

      test('should return failure when update fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Update failed');

        when(
          mockDioClient.patch(
            ApiRoutes.userProfile,
            data: anyNamed('data'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource
            .updateProfile(name: 'Updated Name')
            .run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });
    });

    group('updatePassword', () {
      test('should return void when password update is successful', () async {
        // arrange
        when(
          mockDioClient.patch(
            ApiRoutes.updatePassword,
            data: {
              'current_password': 'currentPass123',
              'new_password': 'newPass123',
              'new_password_confirmation': 'newPass123',
            },
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.updatePassword),
            ),
          ),
        );

        // act
        final result = await dataSource
            .updatePassword(
              currentPassword: 'currentPass123',
              newPassword: 'newPass123',
              newPasswordConfirmation: 'newPass123',
            )
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.patch(
            ApiRoutes.updatePassword,
            data: {
              'current_password': 'currentPass123',
              'new_password': 'newPass123',
              'new_password_confirmation': 'newPass123',
            },
          ),
        ).called(1);
      });

      test('should return failure when password update fails', () async {
        // arrange
        final tFailure = ValidationFailure(
          message: 'Invalid password',
          errors: {
            'current_password': ['Password is incorrect'],
          },
        );

        when(
          mockDioClient.patch(
            ApiRoutes.updatePassword,
            data: anyNamed('data'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource
            .updatePassword(
              currentPassword: 'wrongPass',
              newPassword: 'newPass123',
              newPasswordConfirmation: 'newPass123',
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

    group('updatePreferences', () {
      test(
        'should return UserModel when updating preferences with favoriteGroupId',
        () async {
          // arrange
          when(
            mockDioClient.patch(
              ApiRoutes.userPreferences,
              data: {'favorite_group_id': 1},
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: {...tUserJson, 'favorite_group_id': 1},
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiRoutes.userPreferences),
              ),
            ),
          );

          // act
          final result = await dataSource
              .updatePreferences(favoriteGroupId: 1)
              .run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) {
              expect(r.id, equals(tUserModel.id));
              expect(r.favoriteGroupId, equals(1));
            },
          );
          verify(
            mockDioClient.patch(
              ApiRoutes.userPreferences,
              data: {'favorite_group_id': 1},
            ),
          ).called(1);
        },
      );

      test(
        'should return UserModel when updating preferences with null favoriteGroupId',
        () async {
          // arrange
          when(
            mockDioClient.patch(
              ApiRoutes.userPreferences,
              data: {'favorite_group_id': null},
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: {...tUserJson, 'favorite_group_id': null},
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiRoutes.userPreferences),
              ),
            ),
          );

          // act
          final result = await dataSource
              .updatePreferences(favoriteGroupId: null)
              .run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) => expect(r.favoriteGroupId, isNull),
          );
          verify(
            mockDioClient.patch(
              ApiRoutes.userPreferences,
              data: {'favorite_group_id': null},
            ),
          ).called(1);
        },
      );

      test('should return failure when updating preferences fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Update failed');

        when(
          mockDioClient.patch(
            ApiRoutes.userPreferences,
            data: anyNamed('data'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource
            .updatePreferences(favoriteGroupId: 1)
            .run();

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
