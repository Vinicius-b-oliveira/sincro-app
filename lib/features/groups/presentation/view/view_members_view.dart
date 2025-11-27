import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/session/session_notifier.dart';
import 'package:sincro/core/session/session_state.dart';
import 'package:sincro/features/groups/data/models/group_member_model.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_members/group_members_viewmodel.dart';

class ViewMembersView extends HookConsumerWidget {
  final String groupId;
  final GroupModel? group;

  const ViewMembersView({
    required this.groupId,
    this.group,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final provider = groupMembersViewModelProvider(groupId);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    final sessionState = ref.watch(sessionProvider);
    final currentUser = sessionState.whenOrNull(authenticated: (u) => u);

    final amIOwner = currentUser != null && group?.owner?.id == currentUser.id;

    ref.listen(provider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colorScheme.error,
          ),
        );
        viewModel.clearMessages();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: colorScheme.primary,
          ),
        );
        viewModel.clearMessages();
      }
    });

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
      body: state.members.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (members) {
          final myMemberRecord = members.firstWhere(
            (m) => m.id == currentUser?.id,
            orElse: () => GroupMemberModel(
              id: -1,
              name: '',
              email: '',
              role: GroupRole.member,
            ),
          );

          final myRealRole = amIOwner ? GroupRole.owner : myMemberRecord.role;

          return Column(
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
                      'Membros',
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
                child: RefreshIndicator(
                  onRefresh: () => viewModel.loadMembers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isProcessing =
                          state.processingMemberId == member.id;

                      final displayRole = (group?.owner?.id == member.id)
                          ? GroupRole.owner
                          : member.role;

                      return _MemberListItem(
                        member: member,
                        displayRole: displayRole,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        isProcessing: isProcessing,
                        onTap:
                            _canManage(
                              myRealRole,
                              displayRole,
                              member.id,
                              currentUser?.id ?? -1,
                            )
                            ? () => _showMemberActions(
                                context,
                                member,
                                myRealRole,
                                viewModel,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _canManage(
    GroupRole myRole,
    GroupRole targetRole,
    int targetId,
    int myId,
  ) {
    if (targetId == myId) return false;
    if (myRole == GroupRole.owner) return true;
    if (myRole == GroupRole.admin && targetRole == GroupRole.member) {
      return true;
    }
    return false;
  }

  void _showMemberActions(
    BuildContext context,
    GroupMemberModel member,
    GroupRole myRole,
    GroupMembersViewModel viewModel,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MemberActionsBottomSheet(
        member: member,
        myRole: myRole,
        onToggleAdmin: () {
          Navigator.of(context).pop();
          viewModel.toggleAdminRole(member.id, member.role);
        },
        onRemove: () {
          Navigator.of(context).pop();
          _confirmRemoveMember(context, member, viewModel);
        },
      ),
    );
  }

  void _confirmRemoveMember(
    BuildContext context,
    GroupMemberModel member,
    GroupMembersViewModel viewModel,
  ) {
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
              viewModel.removeMember(member.id);
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

class _MemberListItem extends StatelessWidget {
  final GroupMemberModel member;
  final GroupRole displayRole;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback? onTap;
  final bool isProcessing;

  const _MemberListItem({
    required this.member,
    required this.displayRole,
    required this.colorScheme,
    required this.textTheme,
    this.onTap,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary,
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
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
        subtitle: Text(
          member.email,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProcessing)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else ...[
              _RoleBadge(role: displayRole, colorScheme: colorScheme),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.more_vert,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final GroupRole role;
  final ColorScheme colorScheme;

  const _RoleBadge({required this.role, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (role) {
      GroupRole.owner => ('Dono', colorScheme.primary),
      GroupRole.admin => ('Admin', colorScheme.secondary),
      GroupRole.member => ('Membro', colorScheme.outline),
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
  final GroupMemberModel member;
  final GroupRole myRole;
  final VoidCallback onToggleAdmin;
  final VoidCallback onRemove;

  const _MemberActionsBottomSheet({
    required this.member,
    required this.myRole,
    required this.onToggleAdmin,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final canChangeRole = myRole == GroupRole.owner;

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
          Text(
            'Gerenciar ${member.name}',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          if (canChangeRole) ...[
            _ActionButton(
              icon: Icons.admin_panel_settings_outlined,
              title: member.role == GroupRole.admin
                  ? 'Remover como admin'
                  : 'Tornar admin',
              onTap: onToggleAdmin,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
          ],

          _ActionButton(
            icon: Icons.person_remove_outlined,
            title: 'Remover do grupo',
            isDestructive: true,
            onTap: onRemove,
            colorScheme: colorScheme,
            textTheme: textTheme,
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
