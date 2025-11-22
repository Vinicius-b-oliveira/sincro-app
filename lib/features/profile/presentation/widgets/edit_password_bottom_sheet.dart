import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/utils/validators.dart';
import 'package:sincro/features/profile/presentation/viewmodels/profile/profile_state.dart';
import 'package:sincro/features/profile/presentation/viewmodels/profile/profile_viewmodel.dart';

class EditPasswordBottomSheet extends HookConsumerWidget {
  const EditPasswordBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final autovalidateMode = useState(AutovalidateMode.disabled);

    final obscureCurrentPassword = useState(true);
    final obscureNewPassword = useState(true);
    final obscureConfirmPassword = useState(true);

    final profileState = ref.watch(profileViewModelProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Future<void> savePassword() async {
      if (formKey.currentState!.validate()) {
        await ref
            .read(profileViewModelProvider.notifier)
            .updatePassword(
              currentPassword: currentPasswordController.text,
              newPassword: newPasswordController.text,
              newPasswordConfirmation: confirmPasswordController.text,
            );

        final currentState = ref.read(profileViewModelProvider);

        currentState.maybeWhen(
          error: (_) {},
          orElse: () {
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Senha alterada com sucesso!'),
                  backgroundColor: colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      } else {
        autovalidateMode.value = AutovalidateMode.onUserInteraction;
      }
    }

    return Container(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Alterar senha',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              'Digite sua senha atual e a nova senha',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Form(
              key: formKey,
              autovalidateMode: autovalidateMode.value,
              child: Column(
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrentPassword.value,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Senha atual',
                      hintText: 'Digite sua senha atual',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrentPassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          obscureCurrentPassword.value =
                              !obscureCurrentPassword.value;
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    validator: AppValidators.required(
                      'Por favor, digite sua senha atual',
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: newPasswordController,
                    obscureText: obscureNewPassword.value,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Nova senha',
                      hintText: 'Digite a nova senha',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNewPassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          obscureNewPassword.value = !obscureNewPassword.value;
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    validator: AppValidators.compose([
                      AppValidators.required('Por favor, digite a nova senha'),
                      AppValidators.minLength(
                        8,
                        'A senha deve ter pelo menos 8 caracteres',
                      ),
                      (value) {
                        if (value != null &&
                            value == currentPasswordController.text) {
                          return 'A nova senha deve ser diferente da atual';
                        }
                        return null;
                      },
                    ]),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword.value,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Confirmar nova senha',
                      hintText: 'Digite novamente a nova senha',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          obscureConfirmPassword.value =
                              !obscureConfirmPassword.value;
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    validator: AppValidators.match(
                      newPasswordController,
                      'As senhas não coincidem',
                    ),
                    onFieldSubmitted: (_) => savePassword(),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Use uma senha forte com pelo menos 8 caracteres',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: profileState.maybeWhen(
                      loading: () => null,
                      orElse: () =>
                          () => Navigator.of(context).pop(),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(color: colorScheme.outline),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: profileState.maybeWhen(
                      loading: () => null,
                      orElse: () => savePassword,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: profileState.maybeWhen(
                      loading: () => SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      orElse: () => Text(
                        'Alterar senha',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
