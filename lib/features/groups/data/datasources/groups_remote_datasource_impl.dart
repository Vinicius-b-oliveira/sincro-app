import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/network/dio_client.dart';
import 'package:sincro/features/groups/data/datasources/groups_remote_datasource.dart';

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
  }) {
    return _client
        .post(
          ApiRoutes.groups,
          data: {
            'name': name,
            if (description != null) 'description': description,
          },
        )
        .map((response) {
          return GroupModel.fromJson(response.data);
        });
  }

  @override
  TaskEither<AppFailure, GroupModel> getGroup(String id) {
    return _client.get(ApiRoutes.groupById(id)).map((response) {
      return GroupModel.fromJson(response.data);
    });
  }
}
