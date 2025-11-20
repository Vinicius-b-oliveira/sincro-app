import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/network/providers/network_providers.dart';
import 'package:sincro/core/storage/storage_providers.dart';
import 'package:sincro/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sincro/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:sincro/features/auth/data/repositories/auth_repository.dart';
import 'package:sincro/features/auth/data/repositories/auth_repository_impl.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioClientProvider));
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageServiceProvider),
    ref.watch(hiveServiceProvider),
  );
}
