import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/routing/app_routes.dart';
import 'package:sincro/core/utils/validators.dart';
import 'package:sincro/features/groups/presentation/viewmodels/edit_group/edit_group_state.dart';
import 'package:sincro/features/groups/presentation/viewmodels/edit_group/edit_group_viewmodel.dart';

class EditGroupView extends HookConsumerWidget {
  final String groupId;
  final GroupModel? group;

  const EditGroupView({
    required this.groupId,
    this.group,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialName = group?.name ?? '';
    final initialDescription = group?.description ?? '';

    final nameController = useTextEditingController(text: initialName);
    final descriptionController = useTextEditingController(
      text: initialDescription,
    );

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final autovalidateMode = useState(AutovalidateMode.disabled);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final state = ref.watch(editGroupViewModelProvider);

    final isLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    ref.listen(editGroupViewModelProvider, (_, next) {
      next.whenOrNull(
        success: (updatedGroup) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Grupo atualizado com sucesso!'),
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        deleted: () {
          context.go(AppRoutes.groups);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Grupo excluído com sucesso.'),
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

    void saveChanges() {
      if (formKey.currentState!.validate()) {
        FocusScope.of(context).unfocus();
        ref
            .read(editGroupViewModelProvider.notifier)
            .updateGroup(
              id: groupId,
              name: nameController.text.trim(),
              description: descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
            );
      } else {
        autovalidateMode.value = AutovalidateMode.onUserInteraction;
      }
    }

    void confirmDelete() {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Excluir grupo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tem certeza que deseja excluir o grupo "${group?.name}"?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Esta ação não pode ser desfeita e apagará todo o histórico!',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref
                    .read(editGroupViewModelProvider.notifier)
                    .deleteGroup(groupId);
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
              ),
              child: const Text('Excluir'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar grupo',
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
                            labelText: 'Nome do grupo',
                            prefixIcon: Icon(
                              Icons.group_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                          validator: AppValidators.required(
                            'Informe o nome do grupo',
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: descriptionController,
                          textInputAction: TextInputAction.done,
                          maxLines: 4,
                          enabled: !isLoading,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: 'Descrição (opcional)',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 60),
                              child: Icon(
                                Icons.description_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: isLoading ? null : saveChanges,
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
                          'Salvar alterações',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                Card(
                  color: colorScheme.errorContainer.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Zona de perigo',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Excluir o grupo removerá permanentemente todos os dados e histórico.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : confirmDelete,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Excluir grupo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              side: BorderSide(color: colorScheme.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
