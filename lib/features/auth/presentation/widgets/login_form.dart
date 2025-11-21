import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/theme/config/app_colors.dart';
import 'package:sincro/core/utils/validators.dart';
import 'package:sincro/features/auth/presentation/viewmodels/login/login_state.dart';
import 'package:sincro/features/auth/presentation/viewmodels/login/login_viewmodel.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final emailFocusNode = useFocusNode();
    final passwordFocusNode = useFocusNode();

    final isPasswordObscure = useState(true);
    final autovalidateMode = useState(AutovalidateMode.disabled);

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textTheme = Theme.of(context).textTheme;
    final loginState = ref.watch(loginViewModelProvider);

    void submitForm() {
      if (formKey.currentState?.validate() ?? false) {
        FocusScope.of(context).unfocus();

        ref
            .read(loginViewModelProvider.notifier)
            .login(
              emailController.text.trim(),
              passwordController.text,
            );
      } else {
        autovalidateMode.value = AutovalidateMode.onUserInteraction;
      }
    }

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            focusNode: emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(passwordFocusNode),
            style: const TextStyle(color: AppColors.primary),
            decoration: const InputDecoration(
              hintText: 'E-mail',
            ),
            validator: AppValidators.compose([
              AppValidators.required('Informe seu e-mail'),
              AppValidators.email('E-mail inválido'),
            ]),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            obscureText: isPasswordObscure.value,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => submitForm(),
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
              orElse: () => submitForm,
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
        ],
      ),
    );
  }
}
