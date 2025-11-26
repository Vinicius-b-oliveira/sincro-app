import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/routing/app_routes.dart';
import 'package:sincro/features/groups/presentation/viewmodels/groups_list/groups_list_viewmodel.dart';

class GroupsView extends HookConsumerWidget {
  const GroupsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final groupsStateAsync = ref.watch(groupsListViewModelProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(groupsListViewModelProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              groupsStateAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text('Erro ao carregar grupos: $err'),
                ),
                data: (state) {
                  if (state.error != null) {
                    return Center(child: Text(state.error!));
                  }

                  if (state.groups.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Você ainda não participa de nenhum grupo.',
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.groups.length,
                    itemBuilder: (context, index) {
                      final group = state.groups[index];
                      final color = index.isEven
                          ? colorScheme.secondary.withValues(alpha: 0.7)
                          : colorScheme.secondary.withValues(alpha: 0.4);

                      return _GroupListItem(
                        group: group,
                        color: color,
                        textColor: colorScheme.onSecondary,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupListItem extends StatelessWidget {
  final GroupModel group;
  final Color color;
  final Color textColor;

  const _GroupListItem({
    required this.group,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRoutes.groupDetails,
          pathParameters: {'id': group.id.toString()},
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
                        group.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (group.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          group.description!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: textColor.withValues(alpha: 0.8),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textColor.withValues(alpha: 0.7),
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
                        '${group.membersCount} membros',
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
