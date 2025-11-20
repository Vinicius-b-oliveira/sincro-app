import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/theme/theme_providers.dart';
import 'package:sincro/core/utils/logger.dart';

part 'theme_notifier.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  Future<ThemeMode> build() async {
    final repository = ref.watch(themeRepositoryProvider);
    final result = await repository.getThemeMode().run();

    return result.fold(
      (failure) {
        log.e('Falha ao carregar tema inicial: ${failure.message}');
        return ThemeMode.system;
      },
      (mode) => mode,
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = AsyncData(mode);

    final repository = ref.read(themeRepositoryProvider);
    final result = await repository.saveThemeMode(mode).run();

    result.fold(
      (failure) => log.e('Erro ao persistir tema: ${failure.message}'),
      (_) => log.i('Tema persistido: $mode'),
    );
  }

  Future<void> toggleTheme() async {
    final currentMode = state.value ?? ThemeMode.system;
    final newMode = currentMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setTheme(newMode);
  }
}
