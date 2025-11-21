import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/theme/config/app_colors.dart';
import 'package:sincro/features/auth/presentation/viewmodels/signup/signup_state.dart';
import 'package:sincro/features/auth/presentation/viewmodels/signup/signup_viewmodel.dart';
import 'package:sincro/features/auth/presentation/widgets/signup_form.dart';

class SignUpView extends ConsumerWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    ref.listen(signUpViewModelProvider, (_, next) {
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
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: Theme.of(context).inputDecorationTheme
                  .copyWith(
                    fillColor: AppColors.white,
                    hintStyle: const TextStyle(color: AppColors.grey),
                    errorStyle: const TextStyle(
                      color: Color(
                        0xFFB00020,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                Image.asset(
                  'assets/images/logo_dark.png',
                  height: 200,
                ),
                const SizedBox(height: 24),

                Text(
                  'Cadastro',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                const SignUpForm(
                  buttonBackgroundColor: AppColors.primary,
                  buttonTextColor: AppColors.white,
                ),

                const SizedBox(height: 32),

                Column(
                  children: [
                    const Text(
                      'Já possui uma conta?',
                      style: TextStyle(color: AppColors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: Text(
                        'Fazer login',
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
