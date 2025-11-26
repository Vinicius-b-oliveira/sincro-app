import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/group_model.dart';

part 'create_group_state.freezed.dart';

@freezed
sealed class CreateGroupState with _$CreateGroupState {
  const factory CreateGroupState.initial() = _Initial;
  const factory CreateGroupState.loading() = _Loading;
  const factory CreateGroupState.success(GroupModel group) = _Success;
  const factory CreateGroupState.error(String message) = _Error;
}
