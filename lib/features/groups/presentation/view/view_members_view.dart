import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ViewMembersView extends HookConsumerWidget {
  final String groupId;

  const ViewMembersView({
    required this.groupId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // TODO: Substituir por dados reais do provider/API
    final members = _getMockMembers();
    final groupName = _getGroupName(groupId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Membros do grupo',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${members.length} ${members.length == 1 ? 'membro' : 'membros'}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return _MemberListItem(
                  member: member,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  onTap: () => _showMemberActions(context, member),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<GroupMember> _getMockMembers() {
    return [
      GroupMember(
        id: '1',
        name: 'João Silva',
        email: 'joao.silva@email.com',
        role: MemberRole.owner,
        avatarUrl: null,
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      GroupMember(
        id: '2',
        name: 'Maria Santos',
        email: 'maria.santos@email.com',
        role: MemberRole.admin,
        avatarUrl: null,
        joinedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      GroupMember(
        id: '3',
        name: 'Pedro Costa',
        email: 'pedro.costa@email.com',
        role: MemberRole.member,
        avatarUrl: null,
        joinedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      GroupMember(
        id: '4',
        name: 'Ana Oliveira',
        email: 'ana.oliveira@email.com',
        role: MemberRole.member,
        avatarUrl: null,
        joinedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
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

  void _showMemberActions(BuildContext context, GroupMember member) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MemberActionsBottomSheet(member: member),
    );
  }
}

class GroupMember {
  final String id;
  final String name;
  final String email;
  final MemberRole role;
  final String? avatarUrl;
  final DateTime joinedAt;

  GroupMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.joinedAt,
  });
}

enum MemberRole {
  owner,
  admin,
  member,
}

class _MemberListItem extends StatelessWidget {
  final GroupMember member;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  const _MemberListItem({
    required this.member,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary,
          child: Text(
            member.name[0].toUpperCase(),
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.email,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Entrou ${_formatJoinDate(member.joinedAt)}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoleBadge(role: member.role, colorScheme: colorScheme),
            const SizedBox(width: 8),
            Icon(
              Icons.more_vert,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'há ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    } else if (difference.inHours > 0) {
      return 'há ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else {
      return 'há poucos minutos';
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final MemberRole role;
  final ColorScheme colorScheme;

  const _RoleBadge({
    required this.role,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (role) {
      MemberRole.owner => ('Dono', colorScheme.primary),
      MemberRole.admin => ('Admin', colorScheme.secondary),
      MemberRole.member => ('Membro', colorScheme.outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MemberActionsBottomSheet extends StatelessWidget {
  final GroupMember member;

  const _MemberActionsBottomSheet({
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary,
                child: Text(
                  member.name[0].toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      member.email,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (member.role != MemberRole.owner) ...[
            _ActionButton(
              icon: Icons.admin_panel_settings_outlined,
              title: member.role == MemberRole.admin
                  ? 'Remover como admin'
                  : 'Tornar admin',
              onTap: () => _toggleAdmin(context),
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.person_remove_outlined,
              title: 'Remover do grupo',
              isDestructive: true,
              onTap: () => _removeMember(context),
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este é o dono do grupo e não pode ser removido.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleAdmin(BuildContext context) {
    Navigator.of(context).pop();
    final action = member.role == MemberRole.admin
        ? 'removido como'
        : 'promovido a';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.name} foi $action administrador'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeMember(BuildContext context) {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover membro'),
        content: Text(
          'Tem certeza que deseja remover ${member.name} do grupo?',
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
                  content: Text('${member.name} foi removido do grupo'),
                  backgroundColor: Theme.of(context).colorScheme.error,
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
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ActionButton({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? colorScheme.error : colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
