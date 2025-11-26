import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/utils/currency_input_formatter.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/history/history_viewmodel.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/transaction_detail/transaction_detail_state.dart';
import 'package:sincro/features/transactions/transactions_providers.dart';

part 'transaction_detail_viewmodel.g.dart';

@riverpod
class TransactionDetailViewModel extends _$TransactionDetailViewModel {
  @override
  TransactionDetailState build() {
    return const TransactionDetailState.initial();
  }

  Future<void> updateTransaction({
    required int id,
    required String title,
    required String amountStr,
    required TransactionType type,
    required DateTime date,
    required String category,
    String? description,
    int? groupId,
  }) async {
    state = const TransactionDetailState.loading();

    final amount = CurrencyInputFormatter.parseToDouble(amountStr);

    if (amount <= 0) {
      state = const TransactionDetailState.error('Valor inválido');
      return;
    }

    final repository = ref.read(transactionRepositoryProvider);

    final result = await repository
        .updateTransaction(
          id: id,
          title: title,
          amount: amount,
          type: type,
          date: date,
          category: category,
          description: description,
          groupId: groupId,
        )
        .run();

    result.fold(
      (failure) =>
          state = TransactionDetailState.error(_mapFailureMessage(failure)),
      (_) {
        ref.invalidate(historyViewModelProvider);
        state = const TransactionDetailState.success(
          message: 'Transação atualizada!',
        );
      },
    );
  }

  Future<void> deleteTransaction(int id) async {
    state = const TransactionDetailState.loading();

    final repository = ref.read(transactionRepositoryProvider);
    final result = await repository.deleteTransaction(id).run();

    result.fold(
      (failure) =>
          state = TransactionDetailState.error(_mapFailureMessage(failure)),
      (_) {
        ref.invalidate(historyViewModelProvider);
        state = const TransactionDetailState.deleted();
      },
    );
  }

  Future<List<GroupModel>> getAvailableGroups() async {
    final groupsRepository = ref.read(groupsRepositoryProvider);
    final result = await groupsRepository
        .getGroups(page: 1, perPage: 100)
        .run();
    return result.fold(
      (_) => [],
      (paginated) => paginated.data,
    );
  }

  String _mapFailureMessage(AppFailure failure) {
    return switch (failure) {
      ValidationFailure(message: final msg) => msg,
      ServerFailure(message: final msg) => msg,
      _ => failure.message,
    };
  }
}
