import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sincro/core/models/user_model.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

@freezed
abstract class GroupModel with _$GroupModel {
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
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);
}
