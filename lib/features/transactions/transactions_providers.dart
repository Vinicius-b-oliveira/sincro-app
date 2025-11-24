import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/network/providers/network_providers.dart';
import 'package:sincro/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:sincro/features/transactions/data/datasources/transaction_remote_datasource_impl.dart';
import 'package:sincro/features/transactions/data/repositories/transaction_repository.dart';
import 'package:sincro/features/transactions/data/repositories/transaction_repository_impl.dart';

part 'transactions_providers.g.dart';

@riverpod
TransactionRemoteDataSource transactionRemoteDataSource(
  Ref ref,
) {
  return TransactionRemoteDataSourceImpl(ref.watch(dioClientProvider));
}

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepositoryImpl(
    ref.watch(transactionRemoteDataSourceProvider),
  );
}
