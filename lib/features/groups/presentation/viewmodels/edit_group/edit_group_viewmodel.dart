import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/groups/presentation/viewmodels/edit_group/edit_group_state.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_detail/group_detail_viewmodel.dart';
import 'package:sincro/features/groups/presentation/viewmodels/groups_list/groups_list_viewmodel.dart';

part 'edit_group_viewmodel.g.dart';

@riverpod
class EditGroupViewModel extends _$EditGroupViewModel {
  @override
  EditGroupState build() {
    return const EditGroupState.initial();
  }

  Future<void> updateGroup({
    required String id,
    required String name,
    String? description,
  }) async {
    state = const EditGroupState.loading();

    final repository = ref.read(groupsRepositoryProvider);

    final result = await repository
        .updateGroup(id: id, name: name, description: description)
        .run();

    result.fold(
      (failure) => state = EditGroupState.error(_mapFailureMessage(failure)),
      (updatedGroup) {
        ref.invalidate(groupsListViewModelProvider);
        ref.invalidate(groupDetailViewModelProvider(id));

        state = EditGroupState.success(updatedGroup);
      },
    );
  }

  Future<void> deleteGroup(String id) async {
    state = const EditGroupState.loading();

    final repository = ref.read(groupsRepositoryProvider);

    final result = await repository.deleteGroup(id).run();

    result.fold(
      (failure) => state = EditGroupState.error(_mapFailureMessage(failure)),
      (_) {
        ref.invalidate(groupsListViewModelProvider);
        state = const EditGroupState.deleted();
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
