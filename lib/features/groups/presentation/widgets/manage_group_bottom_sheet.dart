import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:sincro/core/routing/app_routes.dart';

class ManageGroupBottomSheet extends HookWidget {
  final String groupName;
  final String groupId;

  const ManageGroupBottomSheet({
    required this.groupName,
    required this.groupId,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
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
            'Gerenciar grupo',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            groupName,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          _buildOptionButton(
            context,
            icon: Icons.people_outline,
            title: 'Ver membros',
            subtitle: 'Visualizar todos os membros do grupo',
            onTap: () => _handleViewMembers(context),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),

          _buildOptionButton(
            context,
            icon: Icons.edit_outlined,
            title: 'Editar grupo',
            subtitle: 'Alterar nome e configurações',
            onTap: () => _handleEditGroup(context),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),

          _buildOptionButton(
            context,
            icon: Icons.settings_outlined,
            title: 'Configurações',
            subtitle: 'Permissões e configurações avançadas',
            onTap: () => _handleSettings(context),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 24),

          OutlinedButton(
            onPressed: () => _handleLeaveGroup(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.exit_to_app_outlined,
                  color: colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sair do grupo',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _handleViewMembers(BuildContext context) {
    Navigator.of(context).pop();
    context.push(AppRoutes.groupMembers.replaceAll(':id', groupId));
  }

  void _handleEditGroup(BuildContext context) {
    Navigator.of(context).pop();
    context.push(AppRoutes.groupEdit.replaceAll(':id', groupId));
  }

  void _handleSettings(BuildContext context) {
    Navigator.of(context).pop();
    context.push(AppRoutes.groupSettings.replaceAll(':id', groupId));
  }

  void _handleLeaveGroup(BuildContext context) {
    Navigator.of(context).pop();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair do grupo'),
          content: Text('Tem certeza que deseja sair do grupo "$groupName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Você saiu do grupo "$groupName"'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
