import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/groups/presentation/viewmodels/create_group/create_group_state.dart';
import 'package:sincro/features/groups/presentation/viewmodels/groups_list/groups_list_viewmodel.dart';

part 'create_group_viewmodel.g.dart';

@riverpod
class CreateGroupViewModel extends _$CreateGroupViewModel {
  @override
  CreateGroupState build() {
    return const CreateGroupState.initial();
  }

  Future<void> createGroup({
    required String name,
    String? description,
    List<String>? initialMembers,
  }) async {
    state = const CreateGroupState.loading();

    final repository = ref.read(groupsRepositoryProvider);

    final result = await repository
        .createGroup(
          name: name,
          description: description,
          initialMembers: initialMembers,
        )
        .run();

    result.fold(
      (failure) {
        final message = switch (failure) {
          ValidationFailure(message: final msg) => msg,
          ServerFailure(message: final msg) => msg,
          _ => failure.message,
        };
        state = CreateGroupState.error(message);
      },
      (group) {
        ref.invalidate(groupsListViewModelProvider);
        state = CreateGroupState.success(group);
      },
    );
  }
}
