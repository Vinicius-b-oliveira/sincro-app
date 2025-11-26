import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/balance_model.dart';
import 'package:sincro/core/network/dio_client.dart';
import 'package:sincro/features/home/data/datasources/home_remote_datasource.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _client;

  HomeRemoteDataSourceImpl(this._client);

  @override
  TaskEither<AppFailure, BalanceModel> getBalance({
    int? groupId,
  }) {
    final queryParams = <String, dynamic>{};

    if (groupId != null) queryParams['group_id'] = groupId;

    return _client.get(ApiRoutes.balance, queryParameters: queryParams).map(
      (response) {
        return BalanceModel.fromJson(response.data);
      },
    );
  }
}
