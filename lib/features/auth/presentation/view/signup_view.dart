import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/routing/app_routes.dart';
import 'package:sincro/core/theme/config/app_colors.dart';

class SignUpView extends HookConsumerWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final isPasswordObscure = useState(true);
    final isConfirmPasswordObscure = useState(true);

    final textTheme = Theme.of(context).textTheme;

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

                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: AppColors.primary),
                  decoration: const InputDecoration(
                    hintText: 'Nome',
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.primary),
                  decoration: const InputDecoration(
                    hintText: 'E-mail',
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: isPasswordObscure.value,
                  style: const TextStyle(color: AppColors.primary),
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordObscure.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        isPasswordObscure.value = !isPasswordObscure.value;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: isConfirmPasswordObscure.value,
                  style: const TextStyle(color: AppColors.primary),
                  decoration: InputDecoration(
                    hintText: 'Confirmar senha',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordObscure.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        isConfirmPasswordObscure.value =
                            !isConfirmPasswordObscure.value;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    context.go(AppRoutes.home);
                  },
                  child: Text(
                    'Cadastrar',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
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
