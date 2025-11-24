import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/history/history_viewmodel.dart';

class HistoryFilterPanel extends ConsumerWidget {
  const HistoryFilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyViewModelProvider);
    final viewModel = ref.read(historyViewModelProvider.notifier);

    final historyState = state.value;

    if (historyState == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange:
                          (historyState.startDate != null &&
                              historyState.endDate != null)
                          ? DateTimeRange(
                              start: historyState.startDate!,
                              end: historyState.endDate!,
                            )
                          : null,
                    );
                    if (picked != null) {
                      viewModel.updateFilters(
                        startDate: picked.start,
                        endDate: picked.end,
                      );
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    (historyState.startDate != null &&
                            historyState.endDate != null)
                        ? '${DateFormat('dd/MM').format(historyState.startDate!)} - ${DateFormat('dd/MM').format(historyState.endDate!)}'
                        : 'Filtrar por Data',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              if (historyState.startDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => viewModel.clearDateFilter(),
                  tooltip: 'Limpar datas',
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Tipo',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Todos',
                isSelected: historyState.typeFilter == null,
                onTap: () => viewModel.updateFilters(type: null),
              ),
              _FilterChip(
                label: 'Receitas',
                isSelected: historyState.typeFilter == TransactionType.income,
                onTap: () =>
                    viewModel.updateFilters(type: TransactionType.income),
                color: const Color(0xFF4CAF50),
              ),
              _FilterChip(
                label: 'Despesas',
                isSelected: historyState.typeFilter == TransactionType.expense,
                onTap: () =>
                    viewModel.updateFilters(type: TransactionType.expense),
                color: const Color(0xFFE53935),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (historyState.availableGroups.isNotEmpty) ...[
            Text(
              'Grupos',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: historyState.availableGroups.map((group) {
                final isSelected = historyState.selectedGroupIds.contains(
                  group.id,
                );
                return _FilterChip(
                  label: group.name,
                  isSelected: isSelected,
                  onTap: () {
                    final List<int> currentList = List.from(
                      historyState.selectedGroupIds,
                    );

                    if (isSelected) {
                      currentList.remove(group.id);
                    } else {
                      currentList.add(group.id);
                    }
                    viewModel.updateFilters(groupIds: currentList);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            'Categorias',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: viewModel.availableCategories.map((category) {
              final isSelected = historyState.selectedCategories.contains(
                category,
              );
              return _FilterChip(
                label: category,
                isSelected: isSelected,
                onTap: () {
                  final List<String> currentList = List.from(
                    historyState.selectedCategories,
                  );

                  if (isSelected) {
                    currentList.remove(category);
                  } else {
                    currentList.add(category);
                  }
                  viewModel.updateFilters(categories: currentList);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      checkmarkColor: theme.colorScheme.onPrimary,
      selectedColor: effectiveColor,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
