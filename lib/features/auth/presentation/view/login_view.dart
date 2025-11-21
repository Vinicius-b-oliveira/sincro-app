import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/routing/app_routes.dart';
import 'package:sincro/core/theme/config/app_colors.dart';
import 'package:sincro/features/auth/presentation/viewmodels/login/login_state.dart';
import 'package:sincro/features/auth/presentation/viewmodels/login/login_viewmodel.dart';
import 'package:sincro/features/auth/presentation/widgets/login_form.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    ref.listen(loginViewModelProvider, (_, next) {
      next.whenOrNull(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: Theme.of(context).inputDecorationTheme
                    .copyWith(
                      fillColor: AppColors.white,
                      hintStyle: const TextStyle(color: AppColors.grey),
                      errorStyle: const TextStyle(
                        color: Color(0xFFFFB4AB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo_dark.png',
                    height: 200,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  const LoginForm(),

                  const SizedBox(height: 48),

                  Column(
                    children: [
                      const Text(
                        'Não possui um cadastro?',
                        style: TextStyle(color: AppColors.white),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.signup),
                        child: Text(
                          'Criar conta',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
