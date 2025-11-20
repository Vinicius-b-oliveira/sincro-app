import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/user_model.dart';

part 'signup_state.freezed.dart';

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState.initial() = _Initial;
  const factory SignUpState.loading() = _Loading;
  const factory SignUpState.success(UserModel user) = _Success;
  const factory SignUpState.error(String message) = _Error;
}
