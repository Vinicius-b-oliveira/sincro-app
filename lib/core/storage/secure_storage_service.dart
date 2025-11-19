import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

import '../errors/app_failure.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

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
}
