import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/routing/app_routes.dart';
import 'package:sincro/core/theme/theme_notifier.dart';
import 'package:sincro/features/profile/presentation/widgets/edit_name_bottom_sheet.dart';
import 'package:sincro/features/profile/presentation/widgets/edit_password_bottom_sheet.dart';
import 'package:sincro/features/profile/presentation/widgets/favorite_group_bottom_sheet.dart';

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
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isDarkMode
                      ? 'Mudar para Tema Claro'
                      : 'Mudar para Tema Escuro',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const FavoriteGroupBottomSheet(),
                  );
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
                    color: colorScheme.onSecondary,
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
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const EditNameBottomSheet(
                          currentName: 'NOME',
                        ),
                      );
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
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const EditPasswordBottomSheet(),
                      );
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
                onPressed: () => context.go(AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Sair da conta',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onError,
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
