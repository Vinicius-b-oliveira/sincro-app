import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/core/session/session_notifier.dart';
import 'package:sincro/core/session/session_state.dart';

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

    final isEditing = useState(false);

    final titleController = useTextEditingController(text: transaction.title);

    final descriptionController = useTextEditingController(
      text: transaction.description ?? '',
    );

    final amountController = useTextEditingController(
      text: transaction.amount.toStringAsFixed(2),
    );

    final selectedType = useState<TransactionType>(transaction.type);
    final selectedDate = useState(transaction.date);

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes da Transação',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: isOwnedByUser
            ? [
                IconButton(
                  onPressed: isLoading.value
                      ? null
                      : () {
                          if (isEditing.value) {
                            _saveTransaction(
                              context,
                              formKey,
                              isLoading,
                              isEditing,
                            );
                          } else {
                            isEditing.value = true;
                          }
                        },
                  icon: Icon(
                    isEditing.value ? Icons.check : Icons.edit,
                  ),
                ),
                if (isEditing.value)
                  IconButton(
                    onPressed: isLoading.value
                        ? null
                        : () {
                            isEditing.value = false;
                            titleController.text = transaction.title;
                            descriptionController.text =
                                transaction.description ?? '';
                            amountController.text = transaction.amount
                                .toStringAsFixed(2);
                            selectedType.value = transaction.type;
                            selectedDate.value = transaction.date;
                          },
                    icon: const Icon(Icons.close),
                  ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                              color:
                                  selectedType.value == TransactionType.income
                                  ? Colors.green
                                  : colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${double.tryParse(amountController.text)?.toStringAsFixed(2) ?? '0,00'}',
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (isEditing.value && isOwnedByUser)
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(
                        Icons.title,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Por favor, digite um título'
                        : null,
                  )
                else
                  _buildInfoCard(
                    context,
                    'Título',
                    titleController.text,
                    Icons.title,
                    colorScheme,
                    textTheme,
                  ),
                const SizedBox(height: 16),

                if (isEditing.value && isOwnedByUser)
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      prefixIcon: Icon(
                        Icons.description,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else
                  _buildInfoCard(
                    context,
                    'Descrição',
                    descriptionController.text.isEmpty
                        ? 'Sem descrição'
                        : descriptionController.text,
                    Icons.description,
                    colorScheme,
                    textTheme,
                  ),
                const SizedBox(height: 16),

                if (isEditing.value && isOwnedByUser)
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Valor',
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Digite um valor';
                      }
                      if (double.tryParse(value.replaceAll(',', '.')) == null) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  )
                else
                  _buildInfoCard(
                    context,
                    'Valor',
                    'R\$ ${double.tryParse(amountController.text)?.toStringAsFixed(2) ?? '0,00'}',
                    Icons.attach_money,
                    colorScheme,
                    textTheme,
                  ),
                const SizedBox(height: 16),

                if (isEditing.value && isOwnedByUser)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTypeSelector(
                            context,
                            TransactionType.income,
                            selectedType,
                            colorScheme,
                            textTheme,
                          ),
                          const SizedBox(width: 12),
                          _buildTypeSelector(
                            context,
                            TransactionType.expense,
                            selectedType,
                            colorScheme,
                            textTheme,
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  _buildInfoCard(
                    context,
                    'Tipo',
                    selectedType.value.label,
                    selectedType.value == TransactionType.income
                        ? Icons.trending_up
                        : Icons.trending_down,
                    colorScheme,
                    textTheme,
                  ),
                const SizedBox(height: 16),

                if (isEditing.value && isOwnedByUser)
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            selectedDate.value,
                          ),
                        );
                        if (time != null) {
                          selectedDate.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data da transação',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                _formatDateTime(selectedDate.value),
                                style: textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildInfoCard(
                    context,
                    'Data da transação',
                    _formatDateTime(selectedDate.value),
                    Icons.calendar_today,
                    colorScheme,
                    textTheme,
                  ),
                const SizedBox(height: 16),

                _buildInfoCard(
                  context,
                  'Criado em',
                  _formatDateTime(transaction.createdAt),
                  Icons.access_time,
                  colorScheme,
                  textTheme,
                ),
                const SizedBox(height: 32),

                if (isOwnedByUser && !isEditing.value)
                  OutlinedButton.icon(
                    onPressed: isLoading.value
                        ? null
                        : () => _showDeleteDialog(context, isLoading),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir transação'),
                  ),

                if (isLoading.value)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(
    BuildContext context,
    TransactionType type,
    ValueNotifier<TransactionType> selectedType,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = selectedType.value == type;
    return Expanded(
      child: InkWell(
        onTap: () => selectedType.value = type,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                type.label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
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
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
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

  void _saveTransaction(
    BuildContext context,
    GlobalKey<FormState> formKey,
    ValueNotifier<bool> isLoading,
    ValueNotifier<bool> isEditing,
  ) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      // TODO: Conectar ao ViewModel real na próxima etapa
      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        isLoading.value = false;
        isEditing.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação atualizada (Mock)!')),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, ValueNotifier<bool> isLoading) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir transação'),
        content: const Text('Tem certeza que deseja excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              isLoading.value = true;
              // TODO: Conectar ao ViewModel real na próxima etapa
              await Future.delayed(const Duration(seconds: 1));
              isLoading.value = false;
              if (context.mounted) {
                context.pop();
              }
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
