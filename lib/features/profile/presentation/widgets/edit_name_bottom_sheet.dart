import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/features/profile/presentation/viewmodels/profile/profile_state.dart';
import 'package:sincro/features/profile/presentation/viewmodels/profile/profile_viewmodel.dart';

class EditNameBottomSheet extends HookConsumerWidget {
  final String currentName;

  const EditNameBottomSheet({
    required this.currentName,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: currentName);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final autovalidateMode = useState(AutovalidateMode.disabled);

    final profileState = ref.watch(profileViewModelProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Future<void> saveName() async {
      if (formKey.currentState!.validate()) {
        await ref
            .read(profileViewModelProvider.notifier)
            .updateName(
              nameController.text.trim(),
            );

        final currentState = ref.read(profileViewModelProvider);

        currentState.maybeWhen(
          error: (_) {},
          orElse: () {
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Nome alterado com sucesso!'),
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
            'Alterar nome',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Digite seu novo nome de exibição',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Form(
            key: formKey,
            autovalidateMode: autovalidateMode.value,
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nome completo',
                hintText: 'Digite seu nome',
                prefixIcon: Icon(
                  Icons.person_outline,
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, digite seu nome';
                }
                if (value.trim().length < 2) {
                  return 'O nome deve ter pelo menos 2 caracteres';
                }
                if (value.trim().length > 50) {
                  return 'O nome deve ter no máximo 50 caracteres';
                }
                return null;
              },
              onFieldSubmitted: (_) => saveName(),
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
                    orElse: () => saveName,
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
                      'Salvar',
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
    );
  }
}
