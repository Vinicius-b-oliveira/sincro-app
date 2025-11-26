import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sincro/core/routing/app_routes.dart';

class DashboardActions extends StatelessWidget {
  final String? groupId;

  const DashboardActions({
    this.groupId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.push(AppRoutes.addTransaction);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Adicionar transação',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            final route = groupId != null
                ? '${AppRoutes.analytics}?groupId=$groupId'
                : AppRoutes.analytics;
            context.push(route);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.analytics, size: 20),
          label: const Text('Análises'),
        ),
      ],
    );
  }
}
