import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/user_model.dart';

part 'session_state.freezed.dart';

@freezed
class SessionState with _$SessionState {
  const factory SessionState.initial() = _Initial;

  const factory SessionState.loading() = _Loading;

  const factory SessionState.unauthenticated() = _Unauthenticated;

  const factory SessionState.authenticated(UserModel user) = _Authenticated;
}
