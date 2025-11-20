import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/constants/storage_keys.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/token_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  TaskEither<AppFailure, String?> read(String key) {
    return TaskEither.tryCatch(
      () => _storage.read(key: key),
      (error, stack) =>
          CacheFailure(message: 'Erro ao ler dados seguros: $error'),
    );
  }

  TaskEither<AppFailure, void> write(String key, String value) {
    return TaskEither.tryCatch(
      () => _storage.write(key: key, value: value),
      (error, stack) =>
          CacheFailure(message: 'Erro ao salvar dados seguros: $error'),
    );
  }

  TaskEither<AppFailure, void> delete(String key) {
    return TaskEither.tryCatch(
      () => _storage.delete(key: key),
      (error, stack) =>
          CacheFailure(message: 'Erro ao deletar dados seguros: $error'),
    );
  }

  TaskEither<AppFailure, void> deleteAll() {
    return TaskEither.tryCatch(
      () => _storage.deleteAll(),
      (error, stack) =>
          CacheFailure(message: 'Erro ao limpar dados seguros: $error'),
    );
  }

  TaskEither<AppFailure, TokenModel?> getTokens() {
    return read(StorageKeys.accessToken).flatMap((accessToken) {
      if (accessToken == null) return TaskEither.right(null);

      return read(StorageKeys.refreshToken).map((refreshToken) {
        if (refreshToken == null) return null;

        return TokenModel(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      });
    });
  }

  TaskEither<AppFailure, void> saveTokens(TokenModel tokens) {
    return write(
      StorageKeys.accessToken,
      tokens.accessToken,
    ).flatMap((_) => write(StorageKeys.refreshToken, tokens.refreshToken));
  }

  TaskEither<AppFailure, void> deleteTokens() {
    return delete(
      StorageKeys.accessToken,
    ).flatMap((_) => delete(StorageKeys.refreshToken));
  }
}
