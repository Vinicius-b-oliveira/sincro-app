import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/core/network/dio_client.dart';
import 'package:sincro/features/groups/data/datasources/groups_remote_datasource.dart';
import 'package:sincro/features/groups/data/models/group_member_model.dart';

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final DioClient _client;

  GroupsRemoteDataSourceImpl(this._client);

  @override
  TaskEither<AppFailure, PaginatedResponse<GroupModel>> getGroups({
    required int page,
    int? perPage,
  }) {
    return _client
        .get(
          ApiRoutes.groups,
          queryParameters: {
            'page': page,
            if (perPage != null) 'per_page': perPage,
          },
        )
        .map((response) {
          return PaginatedResponse<GroupModel>.fromJson(
            response.data,
            (json) => GroupModel.fromJson(json as Map<String, dynamic>),
          );
        });
  }

  @override
  TaskEither<AppFailure, GroupModel> createGroup({
    required String name,
    String? description,
    List<String>? initialMembers,
  }) {
    final data = <String, dynamic>{
      'name': name,
      if (description != null) 'description': description,
      if (initialMembers != null && initialMembers.isNotEmpty)
        'initial_members': initialMembers,
    };

    return _client.post(ApiRoutes.groups, data: data).map((response) {
      return GroupModel.fromJson(response.data);
    });
  }

  @override
  TaskEither<AppFailure, GroupModel> getGroup(String id) {
    return _client.get(ApiRoutes.groupById(id)).map((response) {
      return GroupModel.fromJson(response.data);
    });
  }

  @override
  TaskEither<AppFailure, PaginatedResponse<TransactionModel>>
  getGroupTransactions({
    required String groupId,
    required int page,
  }) {
    return _client
        .get(
          ApiRoutes.groupTransactions(groupId),
          queryParameters: {'page': page},
        )
        .map((response) {
          return PaginatedResponse<TransactionModel>.fromJson(
            response.data,
            (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
          );
        });
  }

  @override
  TaskEither<AppFailure, List<GroupMemberModel>> getGroupMembers(
    String groupId,
  ) {
    return _client.get(ApiRoutes.groupMembers(groupId)).map((response) {
      final list = response.data['data'] as List;

      return list
          .map((e) => GroupMemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  TaskEither<AppFailure, void> removeMember({
    required String groupId,
    required int userId,
  }) {
    return _client
        .delete(ApiRoutes.groupMemberAction(groupId, userId))
        .map((_) {});
  }

  @override
  TaskEither<AppFailure, void> updateMemberRole({
    required String groupId,
    required int userId,
    required String role,
  }) {
    return _client
        .patch(
          ApiRoutes.groupMemberAction(groupId, userId),
          data: {'role': role},
        )
        .map((_) {});
  }
}
