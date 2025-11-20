import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/user_model.dart';

abstract class AuthRepository {
  TaskEither<AppFailure, UserModel> login({
    required String email,
    required String password,
  });

  TaskEither<AppFailure, UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  TaskEither<AppFailure, void> logout();
}
