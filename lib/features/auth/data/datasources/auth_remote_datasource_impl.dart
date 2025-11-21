import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/network/dio_client.dart';
import 'package:sincro/features/auth/data/models/auth_response.dart';

import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  TaskEither<AppFailure, AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client
        .post(
          ApiRoutes.login,
          data: {'email': email, 'password': password},
        )
        .map((response) {
          return AuthResponse.fromJson(response.data);
        });
  }

  @override
  TaskEither<AppFailure, AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _client
        .post(
          ApiRoutes.register,
          data: {
            'name': name,
            'email': email,
            'password': password,
            'password_confirmation': passwordConfirmation,
          },
        )
        .map((response) {
          return AuthResponse.fromJson(response.data);
        });
  }

  @override
  TaskEither<AppFailure, void> logout({required String refreshToken}) {
    return _client
        .post(
          ApiRoutes.logout,
          data: {'refresh_token': refreshToken},
        )
        .map((_) {});
  }
}
