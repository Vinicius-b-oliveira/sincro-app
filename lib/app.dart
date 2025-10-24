import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/routing/app_router.dart';
import 'package:sincro/core/theme/app_theme.dart';
import 'package:sincro/core/theme/theme_notifier.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Sincro',

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      debugShowCheckedModeBanner: false,

      routerConfig: router,
    );
  }
}
