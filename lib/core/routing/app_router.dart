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
import 'package:sincro/features/profile/presentation/view/profile_view.dart';
import 'package:sincro/features/transactions/models/transaction.dart';
import 'package:sincro/features/transactions/presentation/view/add_transaction_view.dart';
import 'package:sincro/features/transactions/presentation/view/history_view.dart';
import 'package:sincro/features/transactions/presentation/view/transaction_detail_view.dart';

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

      GoRoute(
        path: AppRoutes.transactionDetail,
        name: AppRoutes.transactionDetail,
        builder: (context, state) {
          final transactionId = state.pathParameters['id'] ?? '1';
          final id = int.tryParse(transactionId) ?? 1;

          final mockTransactions = {
            1: Transaction(
              id: 1,
              title: 'Uber',
              description: 'Corrida para casa',
              amount: '24.50',
              type: 'expense',
              transactionDate: DateTime.now().subtract(
                const Duration(hours: 4),
              ),
              createdAt: DateTime.now().subtract(const Duration(hours: 4)),
              isOwnedByUser: true,
            ),
            2: Transaction(
              id: 2,
              title: 'Restaurante',
              description: 'Almoço no centro',
              amount: '45.80',
              type: 'expense',
              transactionDate: DateTime.now().subtract(
                const Duration(hours: 12),
              ),
              createdAt: DateTime.now().subtract(const Duration(hours: 12)),
              isOwnedByUser: false,
            ),
            3: Transaction(
              id: 3,
              title: 'Mercado',
              description: 'Compras da semana',
              amount: '312.90',
              type: 'expense',
              transactionDate: DateTime.now().subtract(
                const Duration(days: 1, hours: 6),
              ),
              createdAt: DateTime.now().subtract(
                const Duration(days: 1, hours: 6),
              ),
              isOwnedByUser: false,
            ),
            4: Transaction(
              id: 4,
              title: 'Padaria',
              description: 'Pães e café',
              amount: '18.00',
              type: 'expense',
              transactionDate: DateTime.now().subtract(
                const Duration(days: 2, hours: 10),
              ),
              createdAt: DateTime.now().subtract(
                const Duration(days: 2, hours: 10),
              ),
              isOwnedByUser: true,
            ),
            5: Transaction(
              id: 5,
              title: 'Freelance',
              description: 'Projeto de desenvolvimento web',
              amount: '1200.00',
              type: 'income',
              transactionDate: DateTime.now().subtract(const Duration(days: 3)),
              createdAt: DateTime.now().subtract(const Duration(days: 3)),
              isOwnedByUser: true,
            ),
          };

          final transaction = mockTransactions[id] ?? mockTransactions[1]!;
          return TransactionDetailView(transaction: transaction);
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
