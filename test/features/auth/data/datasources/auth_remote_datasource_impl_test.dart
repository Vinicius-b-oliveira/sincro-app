import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/token_model.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:sincro/features/auth/data/models/auth_response.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = AuthRemoteDataSourceImpl(mockDioClient);
  });

  group('AuthRemoteDataSourceImpl', () {
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

    final tAuthResponseJson = {
      'user': {
        'id': 1,
        'name': tName,
        'email': tEmail,
      },
      'tokens': {
        'access_token': 'access_token',
        'refresh_token': 'refresh_token',
      },
    };

    group('login', () {
      test('should return AuthResponse when login is successful', () async {
        // arrange
        when(
          mockDioClient.post(
            ApiRoutes.login,
            data: {'email': tEmail, 'password': tPassword},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tAuthResponseJson,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.login),
            ),
          ),
        );

        // act
        final result = await dataSource
            .login(email: tEmail, password: tPassword)
            .run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.user.email, equals(tAuthResponse.user.email));
            expect(r.user.name, equals(tAuthResponse.user.name));
            expect(
              r.tokens.accessToken,
              equals(tAuthResponse.tokens.accessToken),
            );
          },
        );
        verify(
          mockDioClient.post(
            ApiRoutes.login,
            data: {'email': tEmail, 'password': tPassword},
          ),
        ).called(1);
      });

      test('should return ServerFailure when login fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Invalid credentials');

        when(
          mockDioClient.post(
            ApiRoutes.login,
            data: {'email': tEmail, 'password': tPassword},
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource
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
        'should return AuthResponse when registration is successful',
        () async {
          // arrange
          when(
            mockDioClient.post(
              ApiRoutes.register,
              data: {
                'name': tName,
                'email': tEmail,
                'password': tPassword,
                'password_confirmation': tPasswordConfirmation,
              },
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: tAuthResponseJson,
                statusCode: 201,
                requestOptions: RequestOptions(path: ApiRoutes.register),
              ),
            ),
          );

          // act
          final result = await dataSource
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
              expect(r.user.email, equals(tAuthResponse.user.email));
              expect(r.user.name, equals(tAuthResponse.user.name));
            },
          );
          verify(
            mockDioClient.post(
              ApiRoutes.register,
              data: {
                'name': tName,
                'email': tEmail,
                'password': tPassword,
                'password_confirmation': tPasswordConfirmation,
              },
            ),
          ).called(1);
        },
      );

      test('should return ServerFailure when registration fails', () async {
        // arrange
        final tFailure = ValidationFailure(
          message: 'Validation error',
          errors: {
            'email': ['Email already exists'],
          },
        );

        when(
          mockDioClient.post(
            ApiRoutes.register,
            data: {
              'name': tName,
              'email': tEmail,
              'password': tPassword,
              'password_confirmation': tPasswordConfirmation,
            },
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource
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
          (l) {
            expect(l, isA<ValidationFailure>());
            expect((l as ValidationFailure).errors, isNotNull);
          },
          (r) => fail('Should be left'),
        );
      });
    });

    group('logout', () {
      const tRefreshToken = 'refresh_token';

      test('should return void when logout is successful', () async {
        // arrange
        when(
          mockDioClient.post(
            ApiRoutes.logout,
            data: {'refresh_token': tRefreshToken},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.logout),
            ),
          ),
        );

        // act
        final result = await dataSource
            .logout(refreshToken: tRefreshToken)
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.post(
            ApiRoutes.logout,
            data: {'refresh_token': tRefreshToken},
          ),
        ).called(1);
      });

      test('should return ServerFailure when logout fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Logout failed');

        when(
          mockDioClient.post(
            ApiRoutes.logout,
            data: {'refresh_token': tRefreshToken},
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource
            .logout(refreshToken: tRefreshToken)
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
