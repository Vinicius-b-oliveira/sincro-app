import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/network/providers/network_providers.dart';
import 'package:sincro/core/storage/storage_providers.dart';
import 'package:sincro/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sincro/features/profile/data/datasources/profile_remote_datasource_impl.dart';
import 'package:sincro/features/profile/data/repositories/profile_repository.dart';
import 'package:sincro/features/profile/data/repositories/profile_repository_impl.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRemoteDataSource profileRemoteDataSource(
  Ref ref,
) {
  return ProfileRemoteDataSourceImpl(
    ref.watch(dioClientProvider),
  );
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    ref.watch(profileRemoteDataSourceProvider),
    ref.watch(hiveServiceProvider),
  );
}
