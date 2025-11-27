import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/user_model.dart';

part 'invitation_model.freezed.dart';
part 'invitation_model.g.dart';

enum InvitationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined,
}

@freezed
abstract class InvitationModel with _$InvitationModel {
  const factory InvitationModel({
    required int id,
    required InvitationStatus status,
    required GroupModel group,
    required UserModel inviter,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _InvitationModel;

  factory InvitationModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationModelFromJson(json);
}
