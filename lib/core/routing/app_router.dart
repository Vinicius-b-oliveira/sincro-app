import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/routing/app_routes.dart';
import 'package:sincro/core/widgets/app_shell.dart';
import 'package:sincro/features/auth/presentation/view/login_view.dart';
import 'package:sincro/features/auth/presentation/view/signup_view.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (context, state) => const Placeholder(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signup,
        builder: (context, state) => const SignUpView(),
      ),

      GoRoute(
        path: AppRoutes.addTransaction,
        name: AppRoutes.addTransaction,
        builder: (context, state) => const Placeholder(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.home,
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: AppRoutes.history,
            name: AppRoutes.history,
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: AppRoutes.groups,
            name: AppRoutes.groups,
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: AppRoutes.profile,
            builder: (context, state) => const Placeholder(),
          ),
        ],
      ),
    ],
  );
}
