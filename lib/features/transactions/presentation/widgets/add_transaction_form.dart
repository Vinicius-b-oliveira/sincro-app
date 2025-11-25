import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sincro/core/constants/transaction_categories.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/session/session_notifier.dart';
import 'package:sincro/core/session/session_state.dart';
import 'package:sincro/core/utils/currency_input_formatter.dart';
import 'package:sincro/core/utils/validators.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/add_transaction/add_transaction_viewmodel.dart';

class AddTransactionForm extends HookConsumerWidget {
  const AddTransactionForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final currentUser = sessionState.whenOrNull(authenticated: (u) => u);

    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final amountController = useTextEditingController();
    final dateController = useTextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );

    final transactionType = useState(TransactionType.expense);
    final selectedDate = useState(DateTime.now());

    final selectedGroupId = useState<int?>(currentUser?.favoriteGroupId);

    final selectedCategory = useState<String?>(null);

    final autovalidateMode = useState(AutovalidateMode.disabled);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final state = ref.watch(addTransactionViewModelProvider);
    final availableGroups = state.value?.availableGroups ?? [];
    final isLoading = state.value?.isLoading ?? false;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final safeGroupId =
        availableGroups.any((g) => g.id == selectedGroupId.value)
        ? selectedGroupId.value
        : null;

    final currentCategories = transactionType.value == TransactionType.income
        ? TransactionCategories.income
        : TransactionCategories.expense;

    useEffect(() {
      if (selectedCategory.value != null &&
          !currentCategories.contains(selectedCategory.value)) {
        selectedCategory.value = null;
      }
      return null;
    }, [transactionType.value]);

    void submitForm() {
      if (formKey.currentState?.validate() ?? false) {
        if (selectedCategory.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selecione uma categoria')),
          );
          return;
        }

        ref
            .read(addTransactionViewModelProvider.notifier)
            .createTransaction(
              title: titleController.text.trim(),
              amountStr: amountController.text.trim(),
              type: transactionType.value,
              date: selectedDate.value,
              category: selectedCategory.value!,
              description: descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
              groupId: selectedGroupId.value,
            );
      } else {
        autovalidateMode.value = AutovalidateMode.onUserInteraction;
      }
    }

    InputDecoration buildInputDecoration({
      required String label,
      IconData? prefixIcon,
      String? hintText,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      );
    }

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<TransactionType>(
            style: SegmentedButton.styleFrom(
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              selectedBackgroundColor:
                  transactionType.value == TransactionType.income
                  ? const Color(0xFF4CAF50)
                  : colorScheme.error,
              selectedForegroundColor: Colors.white,
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            segments: [
              const ButtonSegment(
                value: TransactionType.expense,
                label: Text('Despesa'),
                icon: Icon(Icons.arrow_downward),
              ),
              const ButtonSegment(
                value: TransactionType.income,
                label: Text('Receita'),
                icon: Icon(Icons.arrow_upward),
              ),
            ],
            selected: {transactionType.value},
            onSelectionChanged: (newSelection) {
              transactionType.value = newSelection.first;
            },
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: buildInputDecoration(
              label: 'Título',
              hintText: 'Ex: Almoço, Salário',
              prefixIcon: Icons.title,
            ),
            validator: AppValidators.required('Informe um título'),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            decoration: buildInputDecoration(
              label: 'Valor',
              prefixIcon: Icons.attach_money,
            ),
            validator: AppValidators.compose([
              AppValidators.required('Informe o valor'),
              (value) {
                if (CurrencyInputFormatter.parseToDouble(value ?? '') <= 0) {
                  return 'Valor inválido';
                }
                return null;
              },
            ]),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: dateController,
            readOnly: true,
            decoration: buildInputDecoration(
              label: 'Data',
              prefixIcon: Icons.calendar_today,
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                selectedDate.value = picked;
                dateController.text = DateFormat('dd/MM/yyyy').format(picked);
              }
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: selectedCategory.value,
            decoration: buildInputDecoration(
              label: 'Categoria',
              prefixIcon: Icons.category_outlined,
            ),
            items: currentCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) => selectedCategory.value = value,
            validator: (value) =>
                value == null ? 'Selecione uma categoria' : null,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            initialValue: safeGroupId,
            decoration: buildInputDecoration(
              label: 'Grupo (Opcional)',
              prefixIcon: Icons.group_outlined,
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('Pessoal (Nenhum)'),
              ),
              ...availableGroups.map((group) {
                return DropdownMenuItem<int>(
                  value: group.id,
                  child: Text(group.name),
                );
              }),
            ],
            onChanged: (value) => selectedGroupId.value = value,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: descriptionController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration:
                buildInputDecoration(
                  label: 'Descrição (Opcional)',
                  prefixIcon: Icons.description,
                ).copyWith(
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.description),
                  ),
                ),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: isLoading ? null : submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    'Salvar Transação',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
