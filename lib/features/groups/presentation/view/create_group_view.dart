import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/features/groups/presentation/viewmodels/create_group/create_group_state.dart';
import 'package:sincro/features/groups/presentation/viewmodels/create_group/create_group_viewmodel.dart';

class CreateGroupView extends HookConsumerWidget {
  const CreateGroupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final autovalidateMode = useState(AutovalidateMode.disabled);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final state = ref.watch(createGroupViewModelProvider);

    final isLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    ref.listen(createGroupViewModelProvider, (_, next) {
      next.whenOrNull(
        success: (group) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Grupo "${group.name}" criado com sucesso!'),
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

    void createGroup() {
      if (formKey.currentState!.validate()) {
        FocusScope.of(context).unfocus();

        ref
            .read(createGroupViewModelProvider.notifier)
            .createGroup(
              name: nameController.text.trim(),
              description: descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
            );
      } else {
        autovalidateMode.value = AutovalidateMode.onUserInteraction;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Criar grupo',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            autovalidateMode: autovalidateMode.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informações do grupo',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: 'Nome do grupo *',
                            hintText: 'Ex: Apartamento 101, Viagem...',
                            prefixIcon: Icon(
                              Icons.group_outlined,
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
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, digite o nome do grupo';
                            }
                            if (value.trim().length < 3) {
                              return 'O nome deve ter pelo menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: descriptionController,
                          textInputAction: TextInputAction.done,
                          maxLines: 3,
                          enabled: !isLoading,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: 'Descrição (opcional)',
                            hintText: 'Descreva o propósito do grupo...',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 40),
                              child: Icon(
                                Icons.description_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
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
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                          validator: (value) {
                            if (value != null &&
                                value.trim().isNotEmpty &&
                                value.trim().length < 10) {
                              return 'A descrição deve ter pelo menos 10 caracteres';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Opacity(
                  opacity: 0.5,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                color: colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Membros iniciais',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Você poderá convidar membros após criar o grupo.',
                                    style: textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: isLoading ? null : createGroup,
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
                          'Criar grupo',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
