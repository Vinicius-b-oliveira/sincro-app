import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/routing/app_routes.dart';

class GroupsView extends HookConsumerWidget {
  const GroupsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => context.push(AppRoutes.createGroup),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Criar novo grupo',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => context.push(AppRoutes.groupInvites),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Entrar em um grupo',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 48),

            Text(
              'Grupos existentes',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            _buildGroupList(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList(BuildContext context, ColorScheme colorScheme) {
    final groups = [
      (
        id: '1',
        name: 'Ap. 101',
        memberCount: 4,
        totalBalance: 'R\$ 1.250,30',
        description: 'Apartamento compartilhado',
      ),
      (
        id: '2',
        name: 'Viagem FDS',
        memberCount: 6,
        totalBalance: 'R\$ 850,00',
        description: 'Viagem para a praia',
      ),
      (
        id: '3',
        name: 'Presente da Mãe',
        memberCount: 3,
        totalBalance: 'R\$ 320,50',
        description: 'Presente de aniversário',
      ),
      (
        id: '4',
        name: 'Contas da Casa',
        memberCount: 2,
        totalBalance: 'R\$ 2.100,75',
        description: 'Despesas domésticas',
      ),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final color = index.isEven
            ? colorScheme.secondary.withValues(alpha: 0.7)
            : colorScheme.secondary.withValues(alpha: 0.4);

        return _GroupListItem(
          id: group.id,
          name: group.name,
          memberCount: group.memberCount,
          totalBalance: group.totalBalance,
          description: group.description,
          color: color,
          textColor: colorScheme.onSecondary,
        );
      },
    );
  }
}

class _GroupListItem extends StatelessWidget {
  final String id;
  final String name;
  final int memberCount;
  final String totalBalance;
  final String description;
  final Color color;
  final Color textColor;

  const _GroupListItem({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.totalBalance,
    required this.description,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(
          AppRoutes.groupDetails.replaceAll(':id', id),
        );
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.group,
                    size: 20,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalBalance,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people,
                        size: 12,
                        color: textColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$memberCount membros',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
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
