import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/group_model.dart';

part 'groups_list_state.freezed.dart';

@freezed
abstract class GroupsListState with _$GroupsListState {
  const factory GroupsListState({
    @Default([]) List<GroupModel> groups,
    @Default(false) bool isLoading,
    String? error,
  }) = _GroupsListState;
}
