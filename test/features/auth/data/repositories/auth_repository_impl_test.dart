import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/token_model.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/features/auth/data/models/auth_response.dart';
import 'package:sincro/features/auth/data/repositories/auth_repository_impl.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockSecureStorageService mockSecureStorage;
  late MockHiveService mockHiveService;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSecureStorage = MockSecureStorageService();
    mockHiveService = MockHiveService();
    repository = AuthRepositoryImpl(
      mockRemoteDataSource,
      mockSecureStorage,
      mockHiveService,
    );
  });

  group('AuthRepositoryImpl', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tName = 'Test User';
    const tPasswordConfirmation = 'password123';

    final tUserModel = const UserModel(
      id: 1,
      name: tName,
      email: tEmail,
    );

    final tTokenModel = const TokenModel(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
    );

    final tAuthResponse = AuthResponse(
      user: tUserModel,
      tokens: tTokenModel,
    );

    group('login', () {
      test(
        'should return UserModel when login is successful and tokens/user are saved',
        () async {
          // arrange
          when(
            mockRemoteDataSource.login(email: tEmail, password: tPassword),
          ).thenReturn(TaskEither.right(tAuthResponse));

          when(
            mockSecureStorage.saveTokens(tTokenModel),
          ).thenReturn(TaskEither.right(null));

          when(
            mockHiveService.saveUser(tUserModel),
          ).thenReturn(TaskEither.right(null));

          // act
          final result = await repository
              .login(email: tEmail, password: tPassword)
              .run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) {
              expect(r.id, equals(tUserModel.id));
              expect(r.email, equals(tUserModel.email));
              expect(r.name, equals(tUserModel.name));
            },
          );
          verify(
            mockRemoteDataSource.login(email: tEmail, password: tPassword),
          ).called(1);
          verify(mockSecureStorage.saveTokens(tTokenModel)).called(1);
          verify(mockHiveService.saveUser(tUserModel)).called(1);
        },
      );

      test('should return failure when remote datasource fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Invalid credentials');

        when(
          mockRemoteDataSource.login(email: tEmail, password: tPassword),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository
            .login(email: tEmail, password: tPassword)
            .run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
        verifyNever(mockSecureStorage.saveTokens(any));
        verifyNever(mockHiveService.saveUser(any));
      });

      test('should return failure when saving tokens fails', () async {
        // arrange
        final tFailure = CacheFailure(message: 'Storage error');

        when(
          mockRemoteDataSource.login(email: tEmail, password: tPassword),
        ).thenReturn(TaskEither.right(tAuthResponse));

        when(
          mockSecureStorage.saveTokens(tTokenModel),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository
            .login(email: tEmail, password: tPassword)
            .run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
        verifyNever(mockHiveService.saveUser(any));
      });

      test('should return failure when saving user fails', () async {
        // arrange
        final tFailure = CacheFailure(message: 'Storage error');

        when(
          mockRemoteDataSource.login(email: tEmail, password: tPassword),
        ).thenReturn(TaskEither.right(tAuthResponse));

        when(
          mockSecureStorage.saveTokens(tTokenModel),
        ).thenReturn(TaskEither.right(null));

        when(
          mockHiveService.saveUser(tUserModel),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository
            .login(email: tEmail, password: tPassword)
            .run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });
    });

    group('register', () {
      test(
        'should return UserModel when registration is successful and tokens/user are saved',
        () async {
          // arrange
          when(
            mockRemoteDataSource.register(
              name: tName,
              email: tEmail,
              password: tPassword,
              passwordConfirmation: tPasswordConfirmation,
            ),
          ).thenReturn(TaskEither.right(tAuthResponse));

          when(
            mockSecureStorage.saveTokens(tTokenModel),
          ).thenReturn(TaskEither.right(null));

          when(
            mockHiveService.saveUser(tUserModel),
          ).thenReturn(TaskEither.right(null));

          // act
          final result = await repository
              .register(
                name: tName,
                email: tEmail,
                password: tPassword,
                passwordConfirmation: tPasswordConfirmation,
              )
              .run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) {
              expect(r.id, equals(tUserModel.id));
              expect(r.email, equals(tUserModel.email));
            },
          );
          verify(
            mockRemoteDataSource.register(
              name: tName,
              email: tEmail,
              password: tPassword,
              passwordConfirmation: tPasswordConfirmation,
            ),
          ).called(1);
          verify(mockSecureStorage.saveTokens(tTokenModel)).called(1);
          verify(mockHiveService.saveUser(tUserModel)).called(1);
        },
      );

      test('should return failure when remote datasource fails', () async {
        // arrange
        final tFailure = ValidationFailure(
          message: 'Validation error',
          errors: {
            'email': ['Email already exists'],
          },
        );

        when(
          mockRemoteDataSource.register(
            name: tName,
            email: tEmail,
            password: tPassword,
            passwordConfirmation: tPasswordConfirmation,
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository
            .register(
              name: tName,
              email: tEmail,
              password: tPassword,
              passwordConfirmation: tPasswordConfirmation,
            )
            .run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<ValidationFailure>()),
          (r) => fail('Should be left'),
        );
        verifyNever(mockSecureStorage.saveTokens(any));
        verifyNever(mockHiveService.saveUser(any));
      });

      test('should return failure when saving tokens fails', () async {
        // arrange
        final tFailure = CacheFailure(message: 'Storage error');

        when(
          mockRemoteDataSource.register(
            name: tName,
            email: tEmail,
            password: tPassword,
            passwordConfirmation: tPasswordConfirmation,
          ),
        ).thenReturn(TaskEither.right(tAuthResponse));

        when(
          mockSecureStorage.saveTokens(tTokenModel),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository
            .register(
              name: tName,
              email: tEmail,
              password: tPassword,
              passwordConfirmation: tPasswordConfirmation,
            )
            .run();

        // assert
        expect(result.isLeft(), true);
        verifyNever(mockHiveService.saveUser(any));
      });
    });

    group('logout', () {
      test(
        'should delete local data after calling remote logout when tokens exist',
        () async {
          // arrange
          when(
            mockSecureStorage.getTokens(),
          ).thenReturn(TaskEither.right(tTokenModel));

          when(
            mockRemoteDataSource.logout(refreshToken: tTokenModel.refreshToken),
          ).thenReturn(TaskEither.right(null));

          when(
            mockSecureStorage.deleteTokens(),
          ).thenReturn(TaskEither.right(null));

          when(mockHiveService.deleteUser()).thenReturn(TaskEither.right(null));

          // act
          final result = await repository.logout().run();

          // assert
          expect(result.isRight(), true);
          verify(mockSecureStorage.getTokens()).called(1);
          verify(
            mockRemoteDataSource.logout(refreshToken: tTokenModel.refreshToken),
          ).called(1);
          verify(mockSecureStorage.deleteTokens()).called(1);
          verify(mockHiveService.deleteUser()).called(1);
        },
      );

      test('should only delete local data when no tokens exist', () async {
        // arrange
        when(mockSecureStorage.getTokens()).thenReturn(TaskEither.right(null));

        when(
          mockSecureStorage.deleteTokens(),
        ).thenReturn(TaskEither.right(null));

        when(mockHiveService.deleteUser()).thenReturn(TaskEither.right(null));

        // act
        final result = await repository.logout().run();

        // assert
        expect(result.isRight(), true);
        verify(mockSecureStorage.getTokens()).called(1);
        verifyNever(
          mockRemoteDataSource.logout(refreshToken: anyNamed('refreshToken')),
        );
        verify(mockSecureStorage.deleteTokens()).called(1);
        verify(mockHiveService.deleteUser()).called(1);
      });

      test(
        'should still delete local data even when remote logout fails',
        () async {
          // arrange
          final tFailure = ServerFailure(message: 'Logout failed');

          when(
            mockSecureStorage.getTokens(),
          ).thenReturn(TaskEither.right(tTokenModel));

          when(
            mockRemoteDataSource.logout(refreshToken: tTokenModel.refreshToken),
          ).thenReturn(TaskEither.left(tFailure));

          when(
            mockSecureStorage.deleteTokens(),
          ).thenReturn(TaskEither.right(null));

          when(mockHiveService.deleteUser()).thenReturn(TaskEither.right(null));

          // act
          final result = await repository.logout().run();

          // assert
          expect(result.isRight(), true);
          verify(mockSecureStorage.deleteTokens()).called(1);
          verify(mockHiveService.deleteUser()).called(1);
        },
      );

      test('should return failure when getting tokens fails', () async {
        // arrange
        final tFailure = CacheFailure(message: 'Storage error');

        when(
          mockSecureStorage.getTokens(),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.logout().run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
        verifyNever(
          mockRemoteDataSource.logout(refreshToken: anyNamed('refreshToken')),
        );
        verifyNever(mockSecureStorage.deleteTokens());
        verifyNever(mockHiveService.deleteUser());
      });

      test('should return failure when deleting tokens fails', () async {
        // arrange
        final tFailure = CacheFailure(message: 'Delete error');

        when(
          mockSecureStorage.getTokens(),
        ).thenReturn(TaskEither.right(tTokenModel));

        when(
          mockRemoteDataSource.logout(refreshToken: tTokenModel.refreshToken),
        ).thenReturn(TaskEither.right(null));

        when(
          mockSecureStorage.deleteTokens(),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.logout().run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
        verifyNever(mockHiveService.deleteUser());
      });
    });
  });
}
