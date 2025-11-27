import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_settings/group_settings_state.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_settings/group_settings_viewmodel.dart';

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

    final provider = groupSettingsViewModelProvider(groupId);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    ref.listen(provider, (previous, next) {
      next.whenOrNull(
        success: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        exportSuccess: (filePath) async {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(filePath)],
              subject: 'Exportação do grupo',
              text: 'Dados exportados do grupo',
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
      body: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (msg) => Center(child: Text('Erro: $msg')),
        success: (_) => const SizedBox.shrink(),
        exportSuccess: (_) => const SizedBox.shrink(),
        loaded: (group) => SingleChildScrollView(
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
                                group.name,
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
                  value: group.membersCanAddTransactions,
                  onChanged: (value) => viewModel.updateSetting(
                    membersCanAddTransactions: value,
                  ),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 8),

                _SettingToggleCard(
                  title: 'Membros podem convidar outros',
                  description:
                      'Permitir que membros convidem outras pessoas para o grupo',
                  value: group.membersCanInvite,
                  onChanged: (value) => viewModel.updateSetting(
                    membersCanInvite: value,
                  ),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
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
                  onTap: () => viewModel.exportData(),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 8),

                _ActionCard(
                  title: 'Limpar histórico',
                  description: 'Remover todas as transações (mantém membros)',
                  icon: Icons.clear_all_outlined,
                  onTap: () => _showClearHistoryDialog(context, viewModel),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClearHistoryDialog(
    BuildContext context,
    GroupSettingsViewModel viewModel,
  ) {
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
              viewModel.clearHistory();
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

    useEffect(() {
      currentValue.value = value;
      return null;
    }, [value]);

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
