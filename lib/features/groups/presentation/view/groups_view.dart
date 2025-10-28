import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
              onPressed: () {
                // TODO: Lógica para criar novo grupo
              },
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
              onPressed: () {
                // TODO: Lógica para entrar em um grupo
              },
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
      'Ap. 101',
      'Viagem FDS',
      'Presente da Mãe',
      'Contas da Casa',
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final color = index.isEven
            ? colorScheme.secondary.withValues(alpha: .7)
            : colorScheme.secondary.withValues(alpha: .4);

        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            groups[index],
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondary,
            ),
          ),
        );
      },
    );
  }
}
