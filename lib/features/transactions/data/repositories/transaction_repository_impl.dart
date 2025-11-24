import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:sincro/features/transactions/data/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _dataSource;

  TransactionRepositoryImpl(this._dataSource);

  @override
  TaskEither<AppFailure, PaginatedResponse<TransactionModel>> getTransactions({
    required int page,
    String? search,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? groupId,
  }) {
    return _dataSource.getTransactions(
      page: page,
      search: search,
      type: type,
      startDate: startDate,
      endDate: endDate,
      groupId: groupId,
    );
  }

  @override
  TaskEither<AppFailure, TransactionModel> createTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required DateTime date,
    required String category,
    String? description,
    int? groupId,
  }) {
    return _dataSource.createTransaction(
      title: title,
      amount: amount,
      type: type,
      date: date,
      category: category,
      description: description,
      groupId: groupId,
    );
  }

  @override
  TaskEither<AppFailure, TransactionModel> updateTransaction({
    required int id,
    String? title,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? category,
    String? description,
    int? groupId,
  }) {
    return _dataSource.updateTransaction(
      id: id,
      title: title,
      amount: amount,
      type: type,
      date: date,
      category: category,
      description: description,
      groupId: groupId,
    );
  }

  @override
  TaskEither<AppFailure, void> deleteTransaction(int id) {
    return _dataSource.deleteTransaction(id);
  }

  @override
  TaskEither<AppFailure, TransactionModel> getTransaction(int id) {
    return _dataSource.getTransaction(id);
  }
}
