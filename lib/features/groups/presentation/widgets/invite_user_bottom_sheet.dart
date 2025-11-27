import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/utils/validators.dart';
import 'package:sincro/features/groups/presentation/viewmodels/invite_user/invite_user_state.dart';
import 'package:sincro/features/groups/presentation/viewmodels/invite_user/invite_user_viewmodel.dart';

class InviteUserBottomSheet extends HookConsumerWidget {
  final String groupId;

  const InviteUserBottomSheet({
    required this.groupId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final autovalidateMode = useState(AutovalidateMode.disabled);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final state = ref.watch(inviteUserViewModelProvider);
    final isLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    ref.listen(inviteUserViewModelProvider, (_, next) {
      next.whenOrNull(
        success: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Convite enviado para ${emailController.text}'),
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    void sendInvite() {
      if (formKey.currentState!.validate()) {
        FocusScope.of(context).unfocus();
        ref
            .read(inviteUserViewModelProvider.notifier)
            .sendInvite(
              groupId: groupId,
              email: emailController.text.trim(),
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
            'Convidar usuário',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Digite o email do usuário que deseja convidar',
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email do usuário',
                    hintText: 'exemplo@email.com',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: colorScheme.onSurfaceVariant,
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
                  validator: AppValidators.email('Digite um e-mail válido'),
                  onFieldSubmitted: (_) => sendInvite(),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outline),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : sendInvite,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                'Enviar convite',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
