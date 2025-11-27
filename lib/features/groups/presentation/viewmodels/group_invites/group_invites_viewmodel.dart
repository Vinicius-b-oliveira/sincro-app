import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_invites/group_invites_state.dart';
import 'package:sincro/features/groups/presentation/viewmodels/groups_list/groups_list_viewmodel.dart';

part 'group_invites_viewmodel.g.dart';

@riverpod
class GroupInvitesViewModel extends _$GroupInvitesViewModel {
  @override
  GroupInvitesState build() {
    Future.microtask(() => loadInvites());
    return const GroupInvitesState();
  }

  Future<void> loadInvites() async {
    state = state.copyWith(invites: const AsyncValue.loading());

    final repository = ref.read(groupsRepositoryProvider);
    final result = await repository.getPendingInvites().run();

    result.fold(
      (failure) => state = state.copyWith(
        invites: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (list) => state = state.copyWith(invites: AsyncValue.data(list)),
    );
  }

  Future<void> acceptInvite(int inviteId, String groupName) async {
    state = state.copyWith(processingInviteId: inviteId, error: null);

    final repository = ref.read(groupsRepositoryProvider);
    final result = await repository.acceptInvite(inviteId).run();

    result.fold(
      (failure) => state = state.copyWith(
        processingInviteId: null,
        error: _mapFailureMessage(failure),
      ),
      (_) {
        ref.invalidate(groupsListViewModelProvider);

        state = state.copyWith(
          processingInviteId: null,
          successMessage: 'Você entrou no grupo "$groupName"!',
        );
        loadInvites();
      },
    );
  }

  Future<void> declineInvite(int inviteId, String groupName) async {
    state = state.copyWith(processingInviteId: inviteId, error: null);

    final repository = ref.read(groupsRepositoryProvider);
    final result = await repository.declineInvite(inviteId).run();

    result.fold(
      (failure) => state = state.copyWith(
        processingInviteId: null,
        error: _mapFailureMessage(failure),
      ),
      (_) {
        state = state.copyWith(
          processingInviteId: null,
          successMessage: 'Convite recusado.',
        );
        loadInvites();
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
