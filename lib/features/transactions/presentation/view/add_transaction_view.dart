import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/add_transaction/add_transaction_viewmodel.dart';
import 'package:sincro/features/transactions/presentation/widgets/add_transaction_form.dart';

class AddTransactionView extends ConsumerWidget {
  const AddTransactionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen(addTransactionViewModelProvider, (_, next) {
      next.whenOrNull(
        data: (state) {
          if (state.isSuccess) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Transação criada com sucesso!'),
                backgroundColor: colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },

        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro inesperado: $error'),
              backgroundColor: colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Transação'),
        centerTitle: true,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: AddTransactionForm(),
        ),
      ),
    );
  }
}
