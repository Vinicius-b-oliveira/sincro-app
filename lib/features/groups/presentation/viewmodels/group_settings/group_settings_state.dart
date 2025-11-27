import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/group_model.dart';

part 'group_settings_state.freezed.dart';

@freezed
sealed class GroupSettingsState with _$GroupSettingsState {
  const factory GroupSettingsState.initial() = GroupSettingsInitial;
  const factory GroupSettingsState.loading() = GroupSettingsLoading;
  const factory GroupSettingsState.loaded(GroupModel group) =
      GroupSettingsLoaded;
  const factory GroupSettingsState.success(String message) =
      GroupSettingsSuccess;
  const factory GroupSettingsState.error(String message) = GroupSettingsError;
}
