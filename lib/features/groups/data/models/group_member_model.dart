import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/group_model.dart';

part 'group_member_model.freezed.dart';
part 'group_member_model.g.dart';

@freezed
abstract class GroupMemberModel with _$GroupMemberModel {
  const factory GroupMemberModel({
    required int id,
    required String name,
    required String email,
    @JsonKey(name: 'role') required GroupRole role,
  }) = _GroupMemberModel;

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberModelFromJson(json);
}
