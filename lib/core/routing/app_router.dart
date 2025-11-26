import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/core/routing/app_routes.dart';
import 'package:sincro/core/session/session_notifier.dart';
import 'package:sincro/core/session/session_state.dart';
import 'package:sincro/core/widgets/app_shell.dart';
import 'package:sincro/core/widgets/splash_view.dart';
import 'package:sincro/features/analytics/presentation/views/analytics_view.dart';
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
import 'package:sincro/features/profile/presentation/views/profile_view.dart';
import 'package:sincro/features/transactions/presentation/view/add_transaction_view.dart';
import 'package:sincro/features/transactions/presentation/view/history_view.dart';
import 'package:sincro/features/transactions/presentation/view/transaction_detail_view.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(Ref ref) {
  final sessionState = ValueNotifier<SessionState>(
    ref.read(sessionProvider),
  );

  ref.listen(
    sessionProvider,
    (_, next) => sessionState.value = next,
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: sessionState,

    redirect: (context, state) {
      final session = sessionState.value;
      final isGoingTo = state.matchedLocation;
      final isPublicRoute = AppRoutes.publicRoutes.contains(isGoingTo);

      return session.when(
        initial: () => AppRoutes.splash,
        loading: () => AppRoutes.splash,
        unauthenticated: () {
          if (!isPublicRoute || isGoingTo == AppRoutes.splash) {
            return AppRoutes.login;
          }
          return null;
        },
        authenticated: (user) {
          if (isPublicRoute || isGoingTo == AppRoutes.splash) {
            return AppRoutes.home;
          }
          return null;
        },
      );
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashView(),
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
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          // Captura o ID opcional passado via extra
          final initialGroupId = state.extra as int?;

          return MaterialPage(
            child: AddTransactionView(initialGroupId: initialGroupId),
            fullscreenDialog: true,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createGroup,
        name: AppRoutes.createGroup,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateGroupView(),
      ),
      GoRoute(
        path: AppRoutes.groupInvites,
        name: AppRoutes.groupInvites,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GroupInvitesView(),
      ),
      GoRoute(
        path: AppRoutes.groupDetails,
        name: AppRoutes.groupDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? 'ID_PADRAO';
          return GroupDetailView(groupId: groupId);
        },
      ),
      GoRoute(
        path: AppRoutes.groupMembers,
        name: AppRoutes.groupMembers,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? 'ID_PADRAO';
          return ViewMembersView(groupId: groupId);
        },
      ),
      GoRoute(
        path: AppRoutes.groupEdit,
        name: AppRoutes.groupEdit,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? 'ID_PADRAO';
          return EditGroupView(groupId: groupId);
        },
      ),
      GoRoute(
        path: AppRoutes.groupSettings,
        name: AppRoutes.groupSettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? 'ID_PADRAO';
          return GroupSettingsView(groupId: groupId);
        },
      ),
      GoRoute(
        path: AppRoutes.transactionDetail,
        name: AppRoutes.transactionDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final transaction = state.extra as TransactionModel?;

          if (transaction == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Erro')),
              body: const Center(child: Text('Transação não encontrada')),
            );
          }

          return TransactionDetailView(transaction: transaction);
        },
      ),
      GoRoute(
        path: AppRoutes.analytics,
        name: AppRoutes.analytics,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final groupId = state.uri.queryParameters['groupId'];
          return AnalyticsView(groupId: groupId);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(child: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.home,
                builder: (context, state) => const HomeView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                name: AppRoutes.history,
                builder: (context, state) => const HistoryView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.groups,
                name: AppRoutes.groups,
                builder: (context, state) => const GroupsView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.profile,
                builder: (context, state) => const ProfileView(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
