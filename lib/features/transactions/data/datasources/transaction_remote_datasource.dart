import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  TaskEither<AppFailure, PaginatedResponse<TransactionModel>> getTransactions({
    required int page,
    String? search,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? groupId,
    List<String>? categories,
  });

  TaskEither<AppFailure, TransactionModel> createTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required DateTime date,
    required String category,
    String? description,
    int? groupId,
  });

  TaskEither<AppFailure, TransactionModel> updateTransaction({
    required int id,
    String? title,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? category,
    String? description,
    int? groupId,
  });

  TaskEither<AppFailure, void> deleteTransaction(int id);

  TaskEither<AppFailure, TransactionModel> getTransaction(int id);
}
