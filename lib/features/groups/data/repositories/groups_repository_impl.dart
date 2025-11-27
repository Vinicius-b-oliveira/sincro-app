import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/features/groups/data/datasources/groups_remote_datasource.dart';
import 'package:sincro/features/groups/data/models/group_member_model.dart';
import 'package:sincro/features/groups/data/repositories/groups_repository.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource _dataSource;

  GroupsRepositoryImpl(this._dataSource);

  @override
  TaskEither<AppFailure, PaginatedResponse<GroupModel>> getGroups({
    required int page,
    int? perPage,
  }) {
    return _dataSource.getGroups(page: page, perPage: perPage);
  }

  @override
  TaskEither<AppFailure, GroupModel> createGroup({
    required String name,
    String? description,
    List<String>? initialMembers,
  }) {
    return _dataSource.createGroup(
      name: name,
      description: description,
      initialMembers: initialMembers,
    );
  }

  @override
  TaskEither<AppFailure, GroupModel> getGroup(String id) {
    return _dataSource.getGroup(id);
  }

  @override
  TaskEither<AppFailure, PaginatedResponse<TransactionModel>>
  getGroupTransactions({
    required String groupId,
    required int page,
  }) {
    return _dataSource.getGroupTransactions(groupId: groupId, page: page);
  }

  @override
  TaskEither<AppFailure, List<GroupMemberModel>> getGroupMembers(
    String groupId,
  ) {
    return _dataSource.getGroupMembers(groupId);
  }

  @override
  TaskEither<AppFailure, void> removeMember({
    required String groupId,
    required int userId,
  }) {
    return _dataSource.removeMember(groupId: groupId, userId: userId);
  }

  @override
  TaskEither<AppFailure, void> updateMemberRole({
    required String groupId,
    required int userId,
    required GroupRole role,
  }) {
    return _dataSource.updateMemberRole(
      groupId: groupId,
      userId: userId,
      role: role.name,
    );
  }
}
