import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/theme/config/app_colors.dart';
import 'package:sincro/core/utils/validators.dart';
import 'package:sincro/features/auth/presentation/viewmodels/signup/signup_state.dart';
import 'package:sincro/features/auth/presentation/viewmodels/signup/signup_viewmodel.dart';

class SignUpForm extends HookConsumerWidget {
  final Color? buttonBackgroundColor;
  final Color? buttonTextColor;

  const SignUpForm({
    super.key,
    this.buttonBackgroundColor,
    this.buttonTextColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final nameFocusNode = useFocusNode();
    final emailFocusNode = useFocusNode();
    final passwordFocusNode = useFocusNode();
    final confirmFocusNode = useFocusNode();

    final isPasswordObscure = useState(true);
    final isConfirmObscure = useState(true);

    final autovalidateMode = useState(AutovalidateMode.disabled);

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textTheme = Theme.of(context).textTheme;
    final signUpState = ref.watch(signUpViewModelProvider);

    void submitForm() {
      if (formKey.currentState?.validate() ?? false) {
        FocusScope.of(context).unfocus();

        ref
            .read(signUpViewModelProvider.notifier)
            .register(
              name: nameController.text.trim(),
              email: emailController.text.trim(),
              password: passwordController.text,
              passwordConfirmation: confirmPasswordController.text,
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
            controller: nameController,
            focusNode: nameFocusNode,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(emailFocusNode),
            style: const TextStyle(color: AppColors.primary),
            decoration: const InputDecoration(hintText: 'Nome'),
            validator: AppValidators.required('Informe seu nome'),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: emailController,
            focusNode: emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(passwordFocusNode),
            style: const TextStyle(color: AppColors.primary),
            decoration: const InputDecoration(hintText: 'E-mail'),
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
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(confirmFocusNode),
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
                onPressed: () =>
                    isPasswordObscure.value = !isPasswordObscure.value,
              ),
            ),
            validator: AppValidators.compose([
              AppValidators.required('Informe uma senha'),
              AppValidators.minLength(8, 'Mínimo de 8 caracteres'),
            ]),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: confirmPasswordController,
            focusNode: confirmFocusNode,
            obscureText: isConfirmObscure.value,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => submitForm(),
            style: const TextStyle(color: AppColors.primary),
            decoration: InputDecoration(
              hintText: 'Confirmar senha',
              suffixIcon: IconButton(
                icon: Icon(
                  isConfirmObscure.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.primary,
                ),
                onPressed: () =>
                    isConfirmObscure.value = !isConfirmObscure.value,
              ),
            ),
            validator: AppValidators.match(
              passwordController,
              'As senhas não conferem',
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBackgroundColor ?? AppColors.secondary,
              foregroundColor: buttonTextColor ?? AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: signUpState.maybeWhen(
              loading: () => null,
              orElse: () => submitForm,
            ),
            child: signUpState.maybeWhen(
              loading: () => const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              orElse: () => Text(
                'Cadastrar',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: buttonTextColor ?? AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
