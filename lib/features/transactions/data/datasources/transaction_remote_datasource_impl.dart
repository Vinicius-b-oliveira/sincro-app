import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/core/network/dio_client.dart';
import 'package:sincro/features/transactions/data/datasources/transaction_remote_datasource.dart';

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final DioClient _client;

  TransactionRemoteDataSourceImpl(this._client);

  @override
  TaskEither<AppFailure, PaginatedResponse<TransactionModel>> getTransactions({
    required int page,
    String? search,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? groupIds,
    List<String>? categories,
  }) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final queryParams = {
      'page': page,
      if (search != null && search.isNotEmpty) 'search': search,
      if (type != null) 'type': type.name,
      if (startDate != null) 'date_start': dateFormat.format(startDate),
      if (endDate != null) 'date_end': dateFormat.format(endDate),
      if (groupIds != null && groupIds.isNotEmpty) 'group_id[]': groupIds,
      if (categories != null && categories.isNotEmpty) 'category[]': categories,
    };

    return _client
        .get(ApiRoutes.transactions, queryParameters: queryParams)
        .map(
          (response) {
            return PaginatedResponse<TransactionModel>.fromJson(
              response.data,
              (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
            );
          },
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
    return _client
        .post(
          ApiRoutes.transactions,
          data: {
            'title': title,
            'amount': amount,
            'type': type.name,
            'transaction_date': DateFormat('yyyy-MM-dd').format(date),
            'category': category,
            if (description != null) 'description': description,
            if (groupId != null) 'group_id': groupId,
          },
        )
        .map((response) {
          return TransactionModel.fromJson(response.data);
        });
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
    final data = <String, dynamic>{};

    if (title != null) data['title'] = title;
    if (amount != null) data['amount'] = amount;
    if (type != null) data['type'] = type.name;
    if (date != null) {
      data['transaction_date'] = DateFormat('yyyy-MM-dd').format(date);
    }
    if (category != null) data['category'] = category;
    if (description != null) data['description'] = description;
    if (groupId != null) data['group_id'] = groupId;

    return _client
        .put(
          ApiRoutes.transactionById(id),
          data: data,
        )
        .map((response) {
          return TransactionModel.fromJson(response.data);
        });
  }

  @override
  TaskEither<AppFailure, void> deleteTransaction(int id) {
    return _client.delete(ApiRoutes.transactionById(id)).map((_) {});
  }

  @override
  TaskEither<AppFailure, TransactionModel> getTransaction(int id) {
    return _client.get(ApiRoutes.transactionById(id)).map((response) {
      return TransactionModel.fromJson(response.data);
    });
  }
}
