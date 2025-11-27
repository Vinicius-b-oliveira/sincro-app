import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/features/groups/data/models/group_member_model.dart';
import 'package:sincro/features/groups/data/models/invitation_model.dart';

abstract class GroupsRepository {
  TaskEither<AppFailure, PaginatedResponse<GroupModel>> getGroups({
    required int page,
    int? perPage,
  });

  TaskEither<AppFailure, GroupModel> createGroup({
    required String name,
    String? description,
    List<String>? initialMembers,
  });

  TaskEither<AppFailure, GroupModel> getGroup(String id);

  TaskEither<AppFailure, PaginatedResponse<TransactionModel>>
  getGroupTransactions({
    required String groupId,
    required int page,
  });

  TaskEither<AppFailure, List<GroupMemberModel>> getGroupMembers(
    String groupId,
  );

  TaskEither<AppFailure, GroupModel> updateGroup({
    required String id,
    String? name,
    String? description,
    bool? membersCanAddTransactions,
    bool? membersCanInvite,
  });

  TaskEither<AppFailure, void> deleteGroup(String id);

  TaskEither<AppFailure, void> removeMember({
    required String groupId,
    required int userId,
  });

  TaskEither<AppFailure, void> updateMemberRole({
    required String groupId,
    required int userId,
    required GroupRole role,
  });

  TaskEither<AppFailure, void> sendInvite({
    required String groupId,
    required String email,
  });

  TaskEither<AppFailure, List<InvitationModel>> getPendingInvites();

  TaskEither<AppFailure, void> acceptInvite(int invitationId);

  TaskEither<AppFailure, void> declineInvite(int invitationId);

  TaskEither<AppFailure, void> clearHistory(String groupId);

  TaskEither<AppFailure, void> exportGroup({
    required String groupId,
    required String savePath,
  });
}
