import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/balance_model.dart';

abstract class HomeRemoteDataSource {
  TaskEither<AppFailure, BalanceModel> getBalance({
    int? groupId,
  });
}
