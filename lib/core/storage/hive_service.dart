import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:fpdart/fpdart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sincro/core/constants/storage_keys.dart';
import 'package:sincro/core/models/user_model.dart';

import '../errors/app_failure.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(StorageKeys.authBox);
    await Hive.openBox(StorageKeys.preferencesBox);
  }

  TaskEither<AppFailure, void> saveUser(UserModel user) {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(StorageKeys.authBox); // Uso da constante
        await box.put(StorageKeys.userProfile, jsonEncode(user.toJson()));
      },
      (error, stack) => CacheFailure(message: 'Erro ao salvar usuário: $error'),
    );
  }

  TaskEither<AppFailure, UserModel?> getUser() {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(StorageKeys.authBox);
        final userString = box.get(StorageKeys.userProfile) as String?;

        if (userString != null) {
          final json = jsonDecode(userString) as Map<String, dynamic>;
          return UserModel.fromJson(json);
        }
        return null;
      },
      (error, stack) => CacheFailure(message: 'Erro ao ler usuário: $error'),
    );
  }

  TaskEither<AppFailure, void> deleteUser() {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(StorageKeys.authBox);
        await box.delete(StorageKeys.userProfile);
      },
      (error, stack) =>
          CacheFailure(message: 'Erro ao deletar usuário: $error'),
    );
  }

  TaskEither<AppFailure, void> saveThemeMode(ThemeMode mode) {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(StorageKeys.preferencesBox);
        await box.put(StorageKeys.themeMode, mode.name);
      },
      (error, stack) => CacheFailure(message: 'Erro ao salvar tema: $error'),
    );
  }

  TaskEither<AppFailure, ThemeMode> getThemeMode() {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(StorageKeys.preferencesBox);
        final themeName = box.get(StorageKeys.themeMode) as String?;

        if (themeName != null) {
          return ThemeMode.values.firstWhere(
            (e) => e.name == themeName,
            orElse: () => ThemeMode.system,
          );
        }
        return ThemeMode.system;
      },
      (error, stack) => CacheFailure(message: 'Erro ao ler tema: $error'),
    );
  }
}
