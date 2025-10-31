import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum TransactionType { income, expense }

class AddTransactionView extends HookConsumerWidget {
  const AddTransactionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final amountController = useTextEditingController();
    final dateController = useTextEditingController();

    final transactionType = useState(TransactionType.expense);

    final selectedGroup = useState<String?>(null);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Transação'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<TransactionType>(
              style: SegmentedButton.styleFrom(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                selectedBackgroundColor: colorScheme.primary,
                selectedForegroundColor: colorScheme.onPrimary,
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                textStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              segments: [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(
                    'Gasto',
                    style: TextStyle(
                      color: transactionType.value == TransactionType.expense
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: Icon(
                    Icons.arrow_downward,
                    color: transactionType.value == TransactionType.expense
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(
                    'Entrada',
                    style: TextStyle(
                      color: transactionType.value == TransactionType.income
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: Icon(
                    Icons.arrow_upward,
                    color: transactionType.value == TransactionType.income
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
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
              style: textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Título (Ex: Almoço)',
                labelStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Valor',
                labelStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                prefixText: 'R\$ ',
                prefixStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: dateController,
              readOnly: true,
              style: textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Data da Transação',
                labelStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: colorScheme.primary,
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  // TODO: Formatar a data
                  dateController.text = pickedDate.toString().split(' ')[0];
                }
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedGroup.value,
              hint: Text(
                'Grupo (opcional)',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              style: textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Grupo',
                labelStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              dropdownColor: colorScheme.surface,
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('Pessoal (Nenhum)'),
                ),
                DropdownMenuItem(
                  value: 'grupo1',
                  child: Text('Ap. 101'),
                ),
                DropdownMenuItem(
                  value: 'grupo2',
                  child: Text('Viagem FDS'),
                ),
              ],
              onChanged: (value) {
                selectedGroup.value = value;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              style: textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                labelStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                alignLabelWithHint: true,
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                // TODO: Chamar ViewModel para salvar
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Salvar Transação',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
