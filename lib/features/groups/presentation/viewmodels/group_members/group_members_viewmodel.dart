import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_members/group_members_state.dart';

part 'group_members_viewmodel.g.dart';

@riverpod
class GroupMembersViewModel extends _$GroupMembersViewModel {
  @override
  GroupMembersState build(String groupId) {
    Future.microtask(() => loadMembers());
    return const GroupMembersState();
  }

  Future<void> loadMembers() async {
    state = state.copyWith(members: const AsyncValue.loading());

    final repository = ref.read(groupsRepositoryProvider);
    final result = await repository.getGroupMembers(groupId).run();

    result.fold(
      (failure) => state = state.copyWith(
        members: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (list) => state = state.copyWith(members: AsyncValue.data(list)),
    );
  }

  Future<void> removeMember(int memberId) async {
    state = state.copyWith(processingMemberId: memberId, error: null);

    final repository = ref.read(groupsRepositoryProvider);
    final result = await repository
        .removeMember(groupId: groupId, userId: memberId)
        .run();

    result.fold(
      (failure) => state = state.copyWith(
        processingMemberId: null,
        error: _mapFailureMessage(failure),
      ),
      (_) {
        state = state.copyWith(
          processingMemberId: null,
          successMessage: 'Membro removido com sucesso',
        );
        loadMembers();
      },
    );
  }

  Future<void> toggleAdminRole(int memberId, GroupRole currentRole) async {
    if (currentRole == GroupRole.owner) return;

    state = state.copyWith(processingMemberId: memberId, error: null);

    final newRole = currentRole == GroupRole.admin
        ? GroupRole.member
        : GroupRole.admin;

    final repository = ref.read(groupsRepositoryProvider);
    final result = await repository
        .updateMemberRole(groupId: groupId, userId: memberId, role: newRole)
        .run();

    result.fold(
      (failure) => state = state.copyWith(
        processingMemberId: null,
        error: _mapFailureMessage(failure),
      ),
      (_) {
        final action = newRole == GroupRole.admin
            ? 'promovido a'
            : 'removido de';
        state = state.copyWith(
          processingMemberId: null,
          successMessage: 'Membro $action admin',
        );
        loadMembers();
      },
    );
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }

  String _mapFailureMessage(AppFailure failure) {
    return switch (failure) {
      ServerFailure(message: final msg) => msg,
      _ => failure.message,
    };
  }
}
