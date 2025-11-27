import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_detail/group_detail_viewmodel.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_settings/group_settings_state.dart';

part 'group_settings_viewmodel.g.dart';

@riverpod
class GroupSettingsViewModel extends _$GroupSettingsViewModel {
  @override
  GroupSettingsState build(String groupId) {
    Future.microtask(() => loadSettings());
    return const GroupSettingsState.initial();
  }

  Future<void> loadSettings() async {
    state = const GroupSettingsState.loading();
    final repository = ref.read(groupsRepositoryProvider);

    final result = await repository.getGroup(groupId).run();

    result.fold(
      (failure) =>
          state = GroupSettingsState.error(_mapFailureMessage(failure)),
      (group) => state = GroupSettingsState.loaded(group),
    );
  }

  Future<void> updateSetting({
    bool? membersCanAddTransactions,
    bool? membersCanInvite,
  }) async {
    final currentState = state;

    if (currentState is! GroupSettingsLoaded) return;

    final repository = ref.read(groupsRepositoryProvider);

    final result = await repository
        .updateGroup(
          id: groupId,
          membersCanAddTransactions: membersCanAddTransactions,
          membersCanInvite: membersCanInvite,
        )
        .run();

    result.fold(
      (failure) {},
      (updatedGroup) {
        state = GroupSettingsState.loaded(updatedGroup);
        ref.invalidate(groupDetailViewModelProvider(groupId));
      },
    );
  }

  String _mapFailureMessage(AppFailure failure) {
    return switch (failure) {
      ValidationFailure(message: final msg) => msg,
      ServerFailure(message: final msg) => msg,
      _ => failure.message,
    };
  }
}
