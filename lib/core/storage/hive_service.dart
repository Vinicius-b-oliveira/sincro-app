import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:fpdart/fpdart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sincro/core/constants/hive_box_names.dart';
import 'package:sincro/core/models/user_model.dart';

import '../errors/app_failure.dart';

class HiveService {
  static const _userKey = 'user_profile';

  TaskEither<AppFailure, void> saveUser(UserModel user) {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(HiveBoxNames.auth);
        await box.put(_userKey, jsonEncode(user.toJson()));
      },
      (error, stack) => CacheFailure(message: 'Erro ao salvar usuário: $error'),
    );
  }

  TaskEither<AppFailure, UserModel?> getUser() {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(HiveBoxNames.auth);
        final userString = box.get(_userKey) as String?;

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
        final box = Hive.box(HiveBoxNames.auth);
        await box.delete(_userKey);
      },
      (error, stack) =>
          CacheFailure(message: 'Erro ao deletar usuário: $error'),
    );
  }

  static const _themeModeKey = 'theme_mode';

  TaskEither<AppFailure, void> saveThemeMode(ThemeMode mode) {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(HiveBoxNames.preferences);
        await box.put(_themeModeKey, mode.name);
      },
      (error, stack) => CacheFailure(message: 'Erro ao salvar tema: $error'),
    );
  }

  TaskEither<AppFailure, ThemeMode> getThemeMode() {
    return TaskEither.tryCatch(
      () async {
        final box = Hive.box(HiveBoxNames.preferences);
        final themeName = box.get(_themeModeKey) as String?;

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
