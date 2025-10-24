import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/theme/theme_notifier.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isDarkMode
                      ? 'Mudar para Tema Claro'
                      : 'Mudar para Tema Escuro',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  // TODO: Lógica para selecionar grupo
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Selecionar grupo favorito',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              CircleAvatar(
                radius: 60,
                backgroundColor: colorScheme.secondary.withValues(alpha: 0.5),
                child: Icon(
                  Icons.person_outline,
                  size: 60,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'NOME',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'e-mail',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Navegar para alterar nome
                    },
                    child: Text(
                      'alterar nome',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: colorScheme.secondary,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navegar para alterar senha
                    },
                    child: Text(
                      'alterar senha',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: colorScheme.secondary,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: () {
                  // TODO: Lógica de logout (chamar o SessionNotifier)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Sair da conta',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
