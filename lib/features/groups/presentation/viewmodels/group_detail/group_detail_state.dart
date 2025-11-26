import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';
import 'package:sincro/core/models/balance_model.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/transaction_model.dart';

part 'group_detail_state.freezed.dart';

@freezed
abstract class GroupDetailState with _$GroupDetailState {
  const factory GroupDetailState({
    @Default(AsyncValue.loading()) AsyncValue<GroupModel> groupData,
    @Default(AsyncValue.loading()) AsyncValue<BalanceModel> balance,
    @Default(AsyncValue.loading())
    AsyncValue<List<TransactionModel>> recentTransactions,
    @Default(AsyncValue.loading()) AsyncValue<AnalyticsSummaryModel> chartData,
  }) = _GroupDetailState;
}
