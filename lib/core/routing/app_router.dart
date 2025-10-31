import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/routing/app_routes.dart';
import 'package:sincro/core/widgets/app_shell.dart';
import 'package:sincro/features/auth/presentation/view/login_view.dart';
import 'package:sincro/features/auth/presentation/view/signup_view.dart';
import 'package:sincro/features/groups/presentation/view/create_group_view.dart';
import 'package:sincro/features/groups/presentation/view/edit_group_view.dart';
import 'package:sincro/features/groups/presentation/view/group_detail_view.dart';
import 'package:sincro/features/groups/presentation/view/group_invites_view.dart';
import 'package:sincro/features/groups/presentation/view/group_settings_view.dart';
import 'package:sincro/features/groups/presentation/view/groups_view.dart';
import 'package:sincro/features/groups/presentation/view/view_members_view.dart';
import 'package:sincro/features/home/presentation/view/home_view.dart';
import 'package:sincro/features/profile/presentation/profile_view.dart';
import 'package:sincro/features/transactions/presentation/view/add_transaction_view.dart';
import 'package:sincro/features/transactions/presentation/view/history_view.dart';

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
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: AddTransactionView(),
            fullscreenDialog: true,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.createGroup,
        name: AppRoutes.createGroup,
        builder: (context, state) => const CreateGroupView(),
      ),

      GoRoute(
        path: AppRoutes.groupInvites,
        name: AppRoutes.groupInvites,
        builder: (context, state) => const GroupInvitesView(),
      ),

      GoRoute(
        path: AppRoutes.groupDetails,
        name: AppRoutes.groupDetails,
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? 'ID_PADRAO';
          return GroupDetailView(groupId: groupId);
        },
      ),

      GoRoute(
        path: AppRoutes.groupMembers,
        name: AppRoutes.groupMembers,
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? 'ID_PADRAO';
          return ViewMembersView(groupId: groupId);
        },
      ),

      GoRoute(
        path: AppRoutes.groupEdit,
        name: AppRoutes.groupEdit,
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? 'ID_PADRAO';
          return EditGroupView(groupId: groupId);
        },
      ),

      GoRoute(
        path: AppRoutes.groupSettings,
        name: AppRoutes.groupSettings,
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? 'ID_PADRAO';
          return GroupSettingsView(groupId: groupId);
        },
      ),

      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.home,
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: AppRoutes.history,
            name: AppRoutes.history,
            builder: (context, state) => const HistoryView(),
          ),
          GoRoute(
            path: AppRoutes.groups,
            name: AppRoutes.groups,
            builder: (context, state) => const GroupsView(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: AppRoutes.profile,
            builder: (context, state) => const ProfileView(),
          ),
        ],
      ),
    ],
  );
}
