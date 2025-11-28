import 'package:mockito/annotations.dart';
import 'package:sincro/core/network/dio_client.dart';
import 'package:sincro/core/storage/hive_service.dart';
import 'package:sincro/core/storage/secure_storage_service.dart';
import 'package:sincro/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:sincro/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sincro/features/groups/data/datasources/groups_remote_datasource.dart';
import 'package:sincro/features/home/data/datasources/home_remote_datasource.dart';
import 'package:sincro/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sincro/features/transactions/data/datasources/transaction_remote_datasource.dart';

@GenerateMocks([
  DioClient,
  SecureStorageService,
  HiveService,
  AnalyticsRemoteDataSource,
  AuthRemoteDataSource,
  GroupsRemoteDataSource,
  HomeRemoteDataSource,
  ProfileRemoteDataSource,
  TransactionRemoteDataSource,
])
void main() {}
