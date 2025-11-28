import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/features/profile/data/repositories/profile_repository_impl.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late MockHiveService mockHiveService;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    mockHiveService = MockHiveService();
    repository = ProfileRepositoryImpl(mockRemoteDataSource, mockHiveService);
  });

  group('ProfileRepositoryImpl', () {
    const tUserModel = UserModel(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
    );

    group('updateName', () {
      test(
        'should return UserModel and save to hive when update is successful',
        () async {
          // arrange
          final tUpdatedUser = tUserModel.copyWith(name: 'Updated Name');

          when(
            mockRemoteDataSource.updateProfile(name: 'Updated Name'),
          ).thenReturn(TaskEither.right(tUpdatedUser));

          when(
            mockHiveService.saveUser(tUpdatedUser),
          ).thenReturn(TaskEither.right(null));

          // act
          final result = await repository.updateName('Updated Name').run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) {
              expect(r.name, equals('Updated Name'));
              expect(r.id, equals(tUserModel.id));
            },
          );
          verify(
            mockRemoteDataSource.updateProfile(name: 'Updated Name'),
          ).called(1);
          verify(mockHiveService.saveUser(tUpdatedUser)).called(1);
        },
      );

      test('should return failure when remote datasource fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Update failed');

        when(
          mockRemoteDataSource.updateProfile(name: 'Updated Name'),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.updateName('Updated Name').run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
        verifyNever(mockHiveService.saveUser(any));
      });

      test('should return failure when saving to hive fails', () async {
        // arrange
        final tUpdatedUser = tUserModel.copyWith(name: 'Updated Name');
        final tFailure = CacheFailure(message: 'Cache error');

        when(
          mockRemoteDataSource.updateProfile(name: 'Updated Name'),
        ).thenReturn(TaskEither.right(tUpdatedUser));

        when(
          mockHiveService.saveUser(tUpdatedUser),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.updateName('Updated Name').run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });
    });

    group('updatePassword', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockRemoteDataSource.updatePassword(
            currentPassword: 'currentPass123',
            newPassword: 'newPass123',
            newPasswordConfirmation: 'newPass123',
          ),
        ).thenReturn(TaskEither.right(null));

        // act
        final result = await repository
            .updatePassword(
              currentPassword: 'currentPass123',
              newPassword: 'newPass123',
              newPasswordConfirmation: 'newPass123',
            )
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockRemoteDataSource.updatePassword(
            currentPassword: 'currentPass123',
            newPassword: 'newPass123',
            newPasswordConfirmation: 'newPass123',
          ),
        ).called(1);
      });

      test('should return failure when datasource fails', () async {
        // arrange
        final tFailure = ValidationFailure(
          message: 'Invalid password',
          errors: {
            'current_password': ['Password is incorrect'],
          },
        );

        when(
          mockRemoteDataSource.updatePassword(
            currentPassword: anyNamed('currentPassword'),
            newPassword: anyNamed('newPassword'),
            newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository
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

    group('updateFavoriteGroup', () {
      test(
        'should return UserModel and save to hive when update is successful with groupId',
        () async {
          // arrange
          final tUpdatedUser = tUserModel.copyWith(favoriteGroupId: 1);

          when(
            mockRemoteDataSource.updatePreferences(favoriteGroupId: 1),
          ).thenReturn(TaskEither.right(tUpdatedUser));

          when(
            mockHiveService.saveUser(tUpdatedUser),
          ).thenReturn(TaskEither.right(null));

          // act
          final result = await repository.updateFavoriteGroup(1).run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) {
              expect(r.favoriteGroupId, equals(1));
              expect(r.id, equals(tUserModel.id));
            },
          );
          verify(
            mockRemoteDataSource.updatePreferences(favoriteGroupId: 1),
          ).called(1);
          verify(mockHiveService.saveUser(tUpdatedUser)).called(1);
        },
      );

      test(
        'should return UserModel and save to hive when update is successful with null groupId',
        () async {
          // arrange
          final tUpdatedUser = tUserModel.copyWith(favoriteGroupId: null);

          when(
            mockRemoteDataSource.updatePreferences(favoriteGroupId: null),
          ).thenReturn(TaskEither.right(tUpdatedUser));

          when(
            mockHiveService.saveUser(tUpdatedUser),
          ).thenReturn(TaskEither.right(null));

          // act
          final result = await repository.updateFavoriteGroup(null).run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) => expect(r.favoriteGroupId, isNull),
          );
          verify(
            mockRemoteDataSource.updatePreferences(favoriteGroupId: null),
          ).called(1);
          verify(mockHiveService.saveUser(tUpdatedUser)).called(1);
        },
      );

      test('should return failure when remote datasource fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Update failed');

        when(
          mockRemoteDataSource.updatePreferences(favoriteGroupId: 1),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.updateFavoriteGroup(1).run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
        verifyNever(mockHiveService.saveUser(any));
      });

      test('should return failure when saving to hive fails', () async {
        // arrange
        final tUpdatedUser = tUserModel.copyWith(favoriteGroupId: 1);
        final tFailure = CacheFailure(message: 'Cache error');

        when(
          mockRemoteDataSource.updatePreferences(favoriteGroupId: 1),
        ).thenReturn(TaskEither.right(tUpdatedUser));

        when(
          mockHiveService.saveUser(tUpdatedUser),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.updateFavoriteGroup(1).run();

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
