import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sincro/core/constants/transaction_categories.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/core/session/session_notifier.dart';
import 'package:sincro/core/session/session_state.dart';
import 'package:sincro/core/utils/category_utils.dart';
import 'package:sincro/core/utils/currency_input_formatter.dart';
import 'package:sincro/core/utils/validators.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/transaction_detail/transaction_detail_state.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/transaction_detail/transaction_detail_viewmodel.dart';

class TransactionDetailView extends HookConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailView({
    required this.transaction,
    super.key,
  });

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final currentUser = sessionState.whenOrNull(authenticated: (u) => u);

    final isOwnedByUser =
        currentUser != null && transaction.isOwnedBy(currentUser.id);
    final state = ref.watch(transactionDetailViewModelProvider);

    final isEditing = useState(false);

    final titleController = useTextEditingController(text: transaction.title);
    final descriptionController = useTextEditingController(
      text: transaction.description ?? '',
    );

    final amountController = useTextEditingController(
      text: NumberFormat.currency(
        locale: 'pt_BR',
        symbol: '',
      ).format(transaction.amount).trim(),
    );

    final selectedType = useState<TransactionType>(transaction.type);
    final selectedDate = useState(transaction.date);
    final selectedCategory = useState<String?>(transaction.category);
    final selectedGroupId = useState<int?>(transaction.groupId);

    final availableGroups = useState<List<GroupModel>>([]);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final safeGroupId =
        availableGroups.value.any((g) => g.id == selectedGroupId.value)
        ? selectedGroupId.value
        : null;

    useEffect(() {
      if (isEditing.value && availableGroups.value.isEmpty) {
        ref
            .read(transactionDetailViewModelProvider.notifier)
            .getAvailableGroups()
            .then((groups) {
              availableGroups.value = groups;
            });
      }
      return null;
    }, [isEditing.value]);

    ref.listen(transactionDetailViewModelProvider, (_, next) {
      next.whenOrNull(
        success: (message) {
          context.pop();
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: colorScheme.primary,
              ),
            );
          }
        },
        deleted: () {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transação excluída'),
              backgroundColor: colorScheme.primary,
            ),
          );
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: colorScheme.error,
            ),
          );
        },
      );
    });

    final currentCategories = selectedType.value == TransactionType.income
        ? TransactionCategories.income
        : TransactionCategories.expense;

    useEffect(() {
      if (isEditing.value &&
          selectedCategory.value != null &&
          !currentCategories.contains(selectedCategory.value)) {
        selectedCategory.value = null;
      }
      return null;
    }, [selectedType.value]);

    void saveChanges() {
      if (formKey.currentState!.validate()) {
        if (selectedCategory.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selecione uma categoria')),
          );
          return;
        }

        ref
            .read(transactionDetailViewModelProvider.notifier)
            .updateTransaction(
              id: transaction.id,
              title: titleController.text.trim(),
              amountStr: amountController.text,
              type: selectedType.value,
              date: selectedDate.value,
              category: selectedCategory.value!,
              description: descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
              groupId: selectedGroupId.value,
            );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: isOwnedByUser
            ? [
                IconButton(
                  onPressed: state.maybeWhen(
                    loading: () => null,
                    orElse: () => () {
                      if (isEditing.value) {
                        saveChanges();
                      } else {
                        isEditing.value = true;
                      }
                    },
                  ),
                  icon: state.maybeWhen(
                    loading: () => SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    orElse: () =>
                        Icon(isEditing.value ? Icons.check : Icons.edit),
                  ),
                ),
                if (isEditing.value)
                  IconButton(
                    onPressed: state.maybeWhen(
                      loading: () => null,
                      orElse: () => () {
                        isEditing.value = false;
                        titleController.text = transaction.title;
                        descriptionController.text =
                            transaction.description ?? '';
                        amountController.text = NumberFormat.currency(
                          locale: 'pt_BR',
                          symbol: '',
                        ).format(transaction.amount).trim();
                        selectedType.value = transaction.type;
                        selectedDate.value = transaction.date;
                        selectedCategory.value = transaction.category;
                        selectedGroupId.value = transaction.groupId;
                      },
                    ),
                    icon: const Icon(Icons.close),
                  ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      (selectedType.value == TransactionType.income
                              ? Colors.green
                              : colorScheme.error)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        (selectedType.value == TransactionType.income
                                ? Colors.green
                                : colorScheme.error)
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selectedType.value == TransactionType.income
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: selectedType.value == TransactionType.income
                              ? Colors.green
                              : colorScheme.error,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedType.value.label,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: selectedType.value == TransactionType.income
                                ? Colors.green
                                : colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final val = CurrencyInputFormatter.parseToDouble(
                          amountController.text,
                        );
                        return Text(
                          NumberFormat.currency(
                            locale: 'pt_BR',
                            symbol: 'R\$',
                          ).format(val),
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (isEditing.value) ...[
                SegmentedButton<TransactionType>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.onSurface,
                    selectedBackgroundColor:
                        selectedType.value == TransactionType.income
                        ? const Color(0xFF4CAF50)
                        : colorScheme.error,
                    selectedForegroundColor: Colors.white,
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Despesa'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Receita'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                  ],
                  selected: {selectedType.value},
                  onSelectionChanged: (newSelection) {
                    selectedType.value = newSelection.first;
                  },
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: AppValidators.required('Informe o título'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  validator: AppValidators.required('Informe o valor'),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: selectedCategory.value,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: currentCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => selectedCategory.value = v,
                  validator: (v) =>
                      v == null ? 'Selecione uma categoria' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  initialValue: safeGroupId,
                  decoration: const InputDecoration(
                    labelText: 'Grupo',
                    prefixIcon: Icon(Icons.group),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Pessoal (Nenhum)'),
                    ),
                    ...availableGroups.value.map(
                      (g) => DropdownMenuItem(value: g.id, child: Text(g.name)),
                    ),
                  ],
                  onChanged: (v) => selectedGroupId.value = v,
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) selectedDate.value = date;
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_formatDateTime(selectedDate.value)),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else ...[
                _buildInfoCard(
                  context,
                  'Título',
                  titleController.text,
                  Icons.title,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  'Categoria',
                  selectedCategory.value ?? '',
                  CategoryUtils.getIcon(selectedCategory.value ?? ''),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  'Grupo',
                  transaction.groupName ?? 'Pessoal',
                  Icons.group,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  'Data',
                  _formatDateTime(selectedDate.value),
                  Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                if (descriptionController.text.isNotEmpty)
                  _buildInfoCard(
                    context,
                    'Descrição',
                    descriptionController.text,
                    Icons.description,
                  ),
              ],

              const SizedBox(height: 32),

              if (isOwnedByUser && !isEditing.value)
                OutlinedButton.icon(
                  onPressed: state.maybeWhen(
                    loading: () => null,
                    orElse: () =>
                        () => _showDeleteDialog(context, ref, transaction.id),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Excluir transação'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir transação'),
        content: const Text('Tem certeza? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(transactionDetailViewModelProvider.notifier)
                  .deleteTransaction(id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
