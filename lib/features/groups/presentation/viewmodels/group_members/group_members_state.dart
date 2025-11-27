import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/features/groups/data/models/group_member_model.dart';

part 'group_members_state.freezed.dart';

@freezed
abstract class GroupMembersState with _$GroupMembersState {
  const factory GroupMembersState({
    @Default(AsyncValue.loading()) AsyncValue<List<GroupMemberModel>> members,
    int? processingMemberId,
    String? error,
    String? successMessage,
  }) = _GroupMembersState;
}
