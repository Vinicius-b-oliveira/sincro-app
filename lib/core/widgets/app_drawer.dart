import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/routing/app_routes.dart'; // Substitua 'sincro' pelo nome do seu projeto

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final String currentLocation = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
            child: Text(
              'Sincro',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Início'),
            selected: currentLocation == AppRoutes.home,
            onTap: () => _navigateTo(context, AppRoutes.home),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Histórico'),
            selected: currentLocation == AppRoutes.history,
            onTap: () => _navigateTo(context, AppRoutes.history),
          ),
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('Grupos'),
            selected: currentLocation == AppRoutes.groups,
            onTap: () => _navigateTo(context, AppRoutes.groups),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfil'),
            selected: currentLocation == AppRoutes.profile,
            onTap: () => _navigateTo(context, AppRoutes.profile),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.of(context).pop();
    GoRouter.of(context).go(route);
  }
}
