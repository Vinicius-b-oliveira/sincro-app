import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/paginated_response.dart';

abstract class GroupsRepository {
  TaskEither<AppFailure, PaginatedResponse<GroupModel>> getGroups({
    required int page,
    int? perPage,
  });

  TaskEither<AppFailure, GroupModel> createGroup({
    required String name,
    String? description,
  });

  TaskEither<AppFailure, GroupModel> getGroup(String id);
}
