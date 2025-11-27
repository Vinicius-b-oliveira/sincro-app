import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/groups/presentation/viewmodels/invite_user/invite_user_state.dart';

part 'invite_user_viewmodel.g.dart';

@riverpod
class InviteUserViewModel extends _$InviteUserViewModel {
  @override
  InviteUserState build() {
    return const InviteUserState.initial();
  }

  Future<void> sendInvite({
    required String groupId,
    required String email,
  }) async {
    state = const InviteUserState.loading();

    final repository = ref.read(groupsRepositoryProvider);

    final result = await repository
        .sendInvite(groupId: groupId, email: email)
        .run();

    result.fold(
      (failure) {
        final message = switch (failure) {
          ValidationFailure(message: final msg) => msg,
          ServerFailure(message: final msg) => msg,
          _ => failure.message,
        };
        state = InviteUserState.error(message);
      },
      (_) {
        state = const InviteUserState.success();
      },
    );
  }
}
