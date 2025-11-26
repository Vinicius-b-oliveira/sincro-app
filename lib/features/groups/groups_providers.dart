import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/network/providers/network_providers.dart';
import 'package:sincro/features/groups/data/datasources/groups_remote_datasource.dart';
import 'package:sincro/features/groups/data/datasources/groups_remote_datasource_impl.dart';
import 'package:sincro/features/groups/data/repositories/groups_repository.dart';
import 'package:sincro/features/groups/data/repositories/groups_repository_impl.dart';

part 'groups_providers.g.dart';

@riverpod
GroupsRemoteDataSource groupsRemoteDataSource(Ref ref) {
  return GroupsRemoteDataSourceImpl(ref.watch(dioClientProvider));
}

@riverpod
GroupsRepository groupsRepository(Ref ref) {
  return GroupsRepositoryImpl(ref.watch(groupsRemoteDataSourceProvider));
}
