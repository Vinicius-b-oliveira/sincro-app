import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/user_model.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

enum GroupRole {
  @JsonValue('owner')
  owner,
  @JsonValue('admin')
  admin,
  @JsonValue('member')
  member;

  bool get isOwner => this == GroupRole.owner;
  bool get isAdmin => this == GroupRole.admin;
  bool get isMember => this == GroupRole.member;
}

@freezed
abstract class GroupModel with _$GroupModel {
  const GroupModel._();

  const factory GroupModel({
    required int id,
    required String name,
    String? description,
    @JsonKey(name: 'members_count') @Default(0) int membersCount,
    UserModel? owner,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'members_can_add_transactions')
    @Default(false)
    bool membersCanAddTransactions,
    @JsonKey(name: 'members_can_invite') @Default(false) bool membersCanInvite,

    @JsonKey(name: 'role') @Default(GroupRole.member) GroupRole role,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);
}
