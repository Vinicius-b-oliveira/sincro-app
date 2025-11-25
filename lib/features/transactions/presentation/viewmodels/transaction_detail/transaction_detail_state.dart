import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_detail_state.freezed.dart';

@freezed
class TransactionDetailState with _$TransactionDetailState {
  const factory TransactionDetailState.initial() = _Initial;
  const factory TransactionDetailState.loading() = _Loading;
  const factory TransactionDetailState.success({String? message}) = _Success;
  const factory TransactionDetailState.error(String message) = _Error;
  const factory TransactionDetailState.deleted() = _Deleted;
}
