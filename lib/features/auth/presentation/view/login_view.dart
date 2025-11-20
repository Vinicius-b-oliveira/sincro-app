import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/routing/app_routes.dart';
import 'package:sincro/core/theme/config/app_colors.dart';
import 'package:sincro/core/utils/validators.dart';
import 'package:sincro/features/auth/presentation/viewmodels/login/login_state.dart';
import 'package:sincro/features/auth/presentation/viewmodels/login/login_viewmodel.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordObscure = useState(true);

    final formKey = useMemoized(() => GlobalKey<FormState>());

    final textTheme = Theme.of(context).textTheme;

    final loginState = ref.watch(loginViewModelProvider);

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: Theme.of(context).inputDecorationTheme
                  .copyWith(
                    fillColor: AppColors.white,
                    hintStyle: const TextStyle(
                      color: AppColors.grey,
                    ),
                    errorStyle: const TextStyle(
                      color: Color(0xFFFFB4AB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

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

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.primary),
                    decoration: const InputDecoration(
                      hintText: 'E-mail',
                    ),
                    validator: AppValidators.email('Informe um e-mail válido'),
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
                    validator: AppValidators.required('Informe sua senha'),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: loginState.maybeWhen(
                      loading: () => null,
                      orElse: () => () {
                        if (formKey.currentState?.validate() ?? false) {
                          ref
                              .read(loginViewModelProvider.notifier)
                              .login(
                                emailController.text,
                                passwordController.text,
                              );
                        }
                      },
                    ),
                    child: loginState.maybeWhen(
                      loading: () => const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      orElse: () => Text(
                        'Entrar',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
