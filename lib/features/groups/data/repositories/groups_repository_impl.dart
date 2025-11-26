import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/features/groups/data/datasources/groups_remote_datasource.dart';
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
}
