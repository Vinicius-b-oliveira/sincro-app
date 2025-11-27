import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/group_model.dart';

part 'edit_group_state.freezed.dart';

@freezed
sealed class EditGroupState with _$EditGroupState {
  const factory EditGroupState.initial() = _Initial;
  const factory EditGroupState.loading() = _Loading;
  const factory EditGroupState.success(GroupModel group) = _Success;
  const factory EditGroupState.deleted() = _Deleted;
  const factory EditGroupState.error(String message) = _Error;
}
