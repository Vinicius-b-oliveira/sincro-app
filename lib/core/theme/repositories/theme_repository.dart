import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';

abstract class ThemeRepository {
  TaskEither<AppFailure, void> saveThemeMode(ThemeMode mode);
  TaskEither<AppFailure, ThemeMode> getThemeMode();
}
