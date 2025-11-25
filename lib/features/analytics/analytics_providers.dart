import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/network/providers/network_providers.dart';
import 'package:sincro/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:sincro/features/analytics/data/datasources/analytics_remote_datasource_impl.dart';
import 'package:sincro/features/analytics/data/repositories/analytics_repository.dart';
import 'package:sincro/features/analytics/data/repositories/analytics_repository_impl.dart';

part 'analytics_providers.g.dart';

@riverpod
AnalyticsRemoteDataSource analyticsRemoteDataSource(
  Ref ref,
) {
  return AnalyticsRemoteDataSourceImpl(ref.watch(dioClientProvider));
}

@riverpod
AnalyticsRepository analyticsRepository(
  Ref ref,
) {
  return AnalyticsRepositoryImpl(ref.watch(analyticsRemoteDataSourceProvider));
}
