import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_user_state.freezed.dart';

@freezed
sealed class InviteUserState with _$InviteUserState {
  const factory InviteUserState.initial() = _Initial;
  const factory InviteUserState.loading() = _Loading;
  const factory InviteUserState.success() = _Success;
  const factory InviteUserState.error(String message) = _Error;
}
