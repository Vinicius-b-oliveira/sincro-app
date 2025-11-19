import 'package:fpdart/fpdart.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../errors/app_failure.dart';

class HiveService {
  static const String _cacheBox = 'sincro_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_cacheBox);
  }

  TaskEither<AppFailure, T?> get<T>(String key) {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(_cacheBox);
        return box.get(key) as T?;
      },
      (error, stack) => CacheFailure(message: 'Erro ao ler cache: $error'),
    );
  }

  TaskEither<AppFailure, void> put<T>(String key, T value) {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(_cacheBox);
        await box.put(key, value);
      },
      (error, stack) =>
          CacheFailure(message: 'Erro ao salvar no cache: $error'),
    );
  }

  TaskEither<AppFailure, void> delete(String key) {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(_cacheBox);
        await box.delete(key);
      },
      (error, stack) =>
          CacheFailure(message: 'Erro ao deletar do cache: $error'),
    );
  }

  TaskEither<AppFailure, void> clear() {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(_cacheBox);
        await box.clear();
      },
      (error, stack) => CacheFailure(message: 'Erro ao limpar cache: $error'),
    );
  }
}
