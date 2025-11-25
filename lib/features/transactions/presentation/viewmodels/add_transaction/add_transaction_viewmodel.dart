import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/utils/currency_input_formatter.dart';
import 'package:sincro/features/profile/profile_providers.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/add_transaction/add_transaction_state.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/history/history_viewmodel.dart';
import 'package:sincro/features/transactions/transactions_providers.dart';

part 'add_transaction_viewmodel.g.dart';

@riverpod
class AddTransactionViewModel extends _$AddTransactionViewModel {
  @override
  Future<AddTransactionState> build() async {
    final groups = await _loadGroups();
    return AddTransactionState(availableGroups: groups);
  }

  Future<void> createTransaction({
    required String title,
    required String amountStr,
    required TransactionType type,
    required DateTime date,
    required String category,
    String? description,
    int? groupId,
  }) async {
    final currentState = state.value ?? const AddTransactionState();
    state = AsyncData(currentState.copyWith(isLoading: true, error: null));

    final amount = CurrencyInputFormatter.parseToDouble(amountStr);

    if (amount <= 0) {
      state = AsyncData(
        currentState.copyWith(isLoading: false, error: 'Valor inválido'),
      );
      return;
    }

    final repository = ref.read(transactionRepositoryProvider);

    final result = await repository
        .createTransaction(
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
      (failure) {
        final message = switch (failure) {
          ValidationFailure(message: final msg) => msg,
          ServerFailure(message: final msg) => msg,
          _ => failure.message,
        };
        state = AsyncData(
          currentState.copyWith(isLoading: false, error: message),
        );
      },
      (transaction) {
        ref.invalidate(historyViewModelProvider);
        state = AsyncData(
          currentState.copyWith(isLoading: false, isSuccess: true),
        );
      },
    );
  }

  Future<List<GroupModel>> _loadGroups() async {
    final profileRepository = ref.read(profileRepositoryProvider);
    final result = await profileRepository.getMyGroups().run();
    return result.getOrElse((_) => []);
  }
}
