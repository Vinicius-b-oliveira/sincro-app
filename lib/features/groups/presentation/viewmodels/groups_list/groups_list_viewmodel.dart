import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/groups/presentation/viewmodels/groups_list/groups_list_state.dart';

part 'groups_list_viewmodel.g.dart';

@riverpod
class GroupsListViewModel extends _$GroupsListViewModel {
  @override
  Future<GroupsListState> build() async {
    return _fetchGroups();
  }

  Future<GroupsListState> _fetchGroups() async {
    final repository = ref.read(groupsRepositoryProvider);

    final result = await repository.getGroups(page: 1, perPage: 100).run();

    return result.fold(
      (failure) => GroupsListState(error: failure.message),
      (response) => GroupsListState(groups: response.data),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGroups());
  }
}
