import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/balance_model.dart';
import 'package:sincro/features/home/data/datasources/home_remote_datasource.dart';
import 'package:sincro/features/home/data/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _dataSource;

  HomeRepositoryImpl(this._dataSource);

  @override
  TaskEither<AppFailure, BalanceModel> getBalance({
    int? groupId,
  }) {
    return _dataSource.getBalance(
      groupId: groupId,
    );
  }
}
