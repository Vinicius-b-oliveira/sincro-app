import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/core/storage/hive_service.dart';
import 'package:sincro/core/storage/secure_storage_service.dart';
import 'package:sincro/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sincro/features/auth/data/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final HiveService _hiveService;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._secureStorage,
    this._hiveService,
  );

  @override
  TaskEither<AppFailure, UserModel> login({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.login(email: email, password: password).flatMap((
      authResponse,
    ) {
      return _secureStorage
          .saveTokens(authResponse.tokens)
          .flatMap((_) => _hiveService.saveUser(authResponse.user))
          .map((_) => authResponse.user);
    });
  }

  @override
  TaskEither<AppFailure, UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _remoteDataSource
        .register(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        )
        .flatMap((authResponse) {
          return _secureStorage
              .saveTokens(authResponse.tokens)
              .flatMap((_) => _hiveService.saveUser(authResponse.user))
              .map((_) => authResponse.user);
        });
  }

  @override
  TaskEither<AppFailure, void> logout() {
    return _remoteDataSource
        .logout()
        .orElse((_) => TaskEither<AppFailure, void>.of(null))
        .flatMap(
          (_) => _secureStorage.deleteTokens().flatMap(
            (_) => _hiveService.deleteUser(),
          ),
        );
  }
}
