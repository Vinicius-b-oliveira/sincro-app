import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/token_model.dart';
import 'package:sincro/core/models/user_model.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required UserModel user,
    required TokenModel tokens,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
