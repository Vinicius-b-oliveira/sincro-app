import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GroupSettingsView extends HookConsumerWidget {
  final String groupId;

  const GroupSettingsView({
    required this.groupId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // TODO: Substituir por dados reais do provider/API
    final settings = _getMockSettings();
    final groupName = _getGroupName(groupId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configurações',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configurações do grupo',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              groupName,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _SectionHeader(
                title: 'Permissões gerais',
                icon: Icons.security_outlined,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 12),

              _SettingToggleCard(
                title: 'Membros podem adicionar transações',
                description:
                    'Permitir que todos os membros adicionem novas transações ao grupo',
                value: settings.membersCanAddTransactions,
                onChanged: (value) =>
                    _updateSetting(context, 'membersCanAddTransactions', value),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 8),

              _SettingToggleCard(
                title: 'Membros podem editar transações',
                description:
                    'Permitir que membros editem transações criadas por eles',
                value: settings.membersCanEditTransactions,
                onChanged: (value) => _updateSetting(
                  context,
                  'membersCanEditTransactions',
                  value,
                ),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 8),

              _SettingToggleCard(
                title: 'Membros podem convidar outros',
                description:
                    'Permitir que membros convidem outras pessoas para o grupo',
                value: settings.membersCanInvite,
                onChanged: (value) =>
                    _updateSetting(context, 'membersCanInvite', value),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 24),

              _SectionHeader(
                title: 'Administradores',
                icon: Icons.admin_panel_settings_outlined,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary,
                        child: Icon(
                          Icons.star,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                      title: const Text('João Silva'),
                      subtitle: const Text(
                        'Proprietário • joao.silva@email.com',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Dono',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ...settings.admins.map(
                      (admin) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.secondary,
                          child: Text(
                            admin.name[0].toUpperCase(),
                            style: TextStyle(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(admin.name),
                        subtitle: Text('Administrador • ${admin.email}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Admin',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () =>
                                  _showAdminOptions(context, admin),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton.icon(
                        onPressed: () => _showPromoteToAdminDialog(context),
                        icon: const Icon(Icons.person_add_outlined),
                        label: const Text('Promover membro a admin'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _SectionHeader(
                title: 'Ações avançadas',
                icon: Icons.build_outlined,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 12),

              _ActionCard(
                title: 'Exportar dados',
                description: 'Baixar todas as transações e dados do grupo',
                icon: Icons.download_outlined,
                onTap: () => _exportData(context),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 8),

              _ActionCard(
                title: 'Limpar histórico',
                description: 'Remover todas as transações (mantém membros)',
                icon: Icons.clear_all_outlined,
                onTap: () => _showClearHistoryDialog(context),
                colorScheme: colorScheme,
                textTheme: textTheme,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  GroupSettingsData _getMockSettings() {
    return GroupSettingsData(
      membersCanAddTransactions: true,
      membersCanEditTransactions: false,
      membersCanInvite: true,
      notifyNewTransactions: true,
      notifyNewMembers: true,
      admins: [
        AdminUser(
          id: '2',
          name: 'Maria Santos',
          email: 'maria.santos@email.com',
        ),
      ],
    );
  }

  String _getGroupName(String id) {
    final groupNames = {
      '1': 'Ap. 101',
      '2': 'Viagem FDS',
      '3': 'Presente da Mãe',
      '4': 'Contas da Casa',
    };
    return groupNames[id] ?? 'Grupo Desconhecido';
  }

  void _updateSetting(BuildContext context, String setting, bool value) {
    // TODO: Implementar atualização real da configuração
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Configuração "$setting" ${value ? 'ativada' : 'desativada'}',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAdminOptions(BuildContext context, AdminUser admin) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opções para ${admin.name}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(
                Icons.person_remove_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Remover como administrador'),
              onTap: () {
                Navigator.of(context).pop();
                _confirmRemoveAdmin(context, admin);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveAdmin(BuildContext context, AdminUser admin) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover administrador'),
        content: Text(
          'Tem certeza que deseja remover ${admin.name} como administrador?',
        ),
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
                  content: Text(
                    '${admin.name} foi removido como administrador',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showPromoteToAdminDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Funcionalidade "Promover a admin" em desenvolvimento',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exportando dados do grupo...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Esta ação irá remover todas as transações do grupo.'),
            SizedBox(height: 16),
            Text(
              'Os membros permanecerão no grupo, mas todo o histórico financeiro será perdido.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
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
                  content: const Text('Histórico do grupo foi limpo'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}

class GroupSettingsData {
  final bool membersCanAddTransactions;
  final bool membersCanEditTransactions;
  final bool membersCanInvite;
  final bool notifyNewTransactions;
  final bool notifyNewMembers;
  final List<AdminUser> admins;

  GroupSettingsData({
    required this.membersCanAddTransactions,
    required this.membersCanEditTransactions,
    required this.membersCanInvite,
    required this.notifyNewTransactions,
    required this.notifyNewMembers,
    required this.admins,
  });
}

class AdminUser {
  final String id;
  final String name;
  final String email;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
  });
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _SettingToggleCard extends HookWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SettingToggleCard({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = useState(value);

    return Card(
      child: SwitchListTile(
        title: Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        value: currentValue.value,
        onChanged: (newValue) {
          currentValue.value = newValue;
          onChanged(newValue);
        },
        activeThumbColor: colorScheme.primary,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? colorScheme.error : colorScheme.primary;

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: colorScheme.onSurfaceVariant,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
