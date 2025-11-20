import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/features/auth/data/models/auth_response.dart';

abstract class AuthRemoteDataSource {
  TaskEither<AppFailure, AuthResponse> login({
    required String email,
    required String password,
  });

  TaskEither<AppFailure, AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  TaskEither<AppFailure, void> logout();
}
