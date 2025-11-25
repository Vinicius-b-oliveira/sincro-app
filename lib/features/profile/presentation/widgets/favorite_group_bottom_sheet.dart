import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/session/session_notifier.dart';
import 'package:sincro/core/session/session_state.dart';
import 'package:sincro/features/profile/presentation/viewmodels/profile/profile_state.dart';
import 'package:sincro/features/profile/presentation/viewmodels/profile/profile_viewmodel.dart';

class FavoriteGroupBottomSheet extends HookConsumerWidget {
  const FavoriteGroupBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = useState<List<GroupModel>>([]);
    final isLoadingGroups = useState(true);

    final selectedGroupId = useState<int?>(null);

    final sessionState = ref.watch(sessionProvider);
    final currentUser = sessionState.whenOrNull(authenticated: (user) => user);
    final currentFavoriteId = currentUser?.favoriteGroupId;

    final profileState = ref.watch(profileViewModelProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    useEffect(() {
      Future<void> loadGroups() async {
        try {
          final fetchedGroups = await ref
              .read(profileViewModelProvider.notifier)
              .getAvailableGroups();

          groups.value = fetchedGroups;

          if (currentFavoriteId != null) {
            selectedGroupId.value = currentFavoriteId;
          }
        } finally {
          isLoadingGroups.value = false;
        }
      }

      loadGroups();
      return null;
    }, []);

    Future<void> saveFavorite() async {
      await ref
          .read(profileViewModelProvider.notifier)
          .updateFavoriteGroup(
            selectedGroupId.value,
          );

      final currentState = ref.read(profileViewModelProvider);
      currentState.maybeWhen(
        error: (_) {},
        orElse: () {
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Grupo favorito atualizado!'),
                backgroundColor: colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
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
            'Selecionar grupo favorito',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Este grupo será exibido em destaque no seu perfil',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Flexible(
            child: isLoadingGroups.value
                ? const Center(child: CircularProgressIndicator())
                : groups.value.isEmpty
                ? _buildEmptyState(colorScheme, textTheme)
                : ListView(
                    shrinkWrap: true,
                    children: [
                      _GroupItem(
                        id: -1,
                        name: 'Nenhum (Pessoal)',
                        memberCount: 0,
                        isCurrentFavorite: currentFavoriteId == null,
                        isSelected: selectedGroupId.value == null,
                        onTap: () => selectedGroupId.value = null,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        isNoneOption: true,
                      ),

                      ...groups.value.map((group) {
                        final isCurrentFavorite = group.id == currentFavoriteId;
                        return _GroupItem(
                          id: group.id,
                          name: group.name,
                          memberCount: group.membersCount,
                          isCurrentFavorite: isCurrentFavorite,
                          isSelected: selectedGroupId.value == group.id,
                          onTap: () {
                            if (selectedGroupId.value == group.id) {
                              selectedGroupId.value = null;
                            } else {
                              selectedGroupId.value = group.id;
                            }
                          },
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        );
                      }),
                    ],
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
                    orElse: () => saveFavorite,
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

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_off_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum grupo encontrado',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você precisa participar de pelo menos um grupo para defini-lo como favorito.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GroupItem extends StatelessWidget {
  final int id;
  final String name;
  final int memberCount;
  final bool isCurrentFavorite;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isNoneOption;

  const _GroupItem({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.isCurrentFavorite,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
    this.isNoneOption = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isNoneOption
                        ? colorScheme.surfaceContainerHighest
                        : (isSelected
                              ? colorScheme.primary
                              : colorScheme.secondary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: isNoneOption
                        ? Icon(
                            Icons.person_off_outlined,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: textTheme.titleMedium?.copyWith(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isCurrentFavorite)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Atual',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!isNoneOption) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$memberCount ${memberCount == 1 ? 'membro' : 'membros'}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 24,
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
