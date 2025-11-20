import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/storage/hive_service.dart';
import 'package:sincro/core/theme/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final HiveService _hiveService;

  ThemeRepositoryImpl(this._hiveService);

  @override
  TaskEither<AppFailure, void> saveThemeMode(ThemeMode mode) {
    return _hiveService.saveThemeMode(mode);
  }

  @override
  TaskEither<AppFailure, ThemeMode> getThemeMode() {
    return _hiveService.getThemeMode();
  }
}
