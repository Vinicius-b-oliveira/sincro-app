import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/network/providers/network_providers.dart';
import 'package:sincro/features/home/data/datasources/home_remote_datasource.dart';
import 'package:sincro/features/home/data/datasources/home_remote_datasource_impl.dart';
import 'package:sincro/features/home/data/repositories/home_repository.dart';
import 'package:sincro/features/home/data/repositories/home_repository_impl.dart';

part 'home_providers.g.dart';

@riverpod
HomeRemoteDataSource homeRemoteDataSource(Ref ref) {
  return HomeRemoteDataSourceImpl(ref.watch(dioClientProvider));
}

@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepositoryImpl(ref.watch(homeRemoteDataSourceProvider));
}
