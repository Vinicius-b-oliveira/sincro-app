import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/features/transactions/presentation/viewmodels/history/history_viewmodel.dart';
import 'package:sincro/features/transactions/presentation/widgets/history_filter_panel.dart';
import 'package:sincro/features/transactions/presentation/widgets/transaction_list_item.dart';

class HistoryView extends HookConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyStateAsync = ref.watch(historyViewModelProvider);
    final viewModel = ref.read(historyViewModelProvider.notifier);

    final searchController = useTextEditingController();
    final scrollController = useScrollController();
    final isFilterExpanded = useState(false);

    final debounceTimer = useRef<Timer?>(null);

    useEffect(() {
      void listener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          viewModel.loadNextPage();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    useEffect(() {
      void listener() {
        debounceTimer.value?.cancel();
        debounceTimer.value = Timer(const Duration(milliseconds: 500), () {
          viewModel.updateFilters(search: searchController.text);
        });
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar transação...',
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      filled: true,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () =>
                            isFilterExpanded.value = !isFilterExpanded.value,
                        icon: Icon(
                          isFilterExpanded.value
                              ? Icons.filter_list_off
                              : Icons.filter_list,
                          size: 18,
                        ),
                        label: Text(
                          isFilterExpanded.value
                              ? 'Ocultar Filtros'
                              : 'Filtros',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFilterExpanded.value
                              ? colorScheme.primary
                              : colorScheme.surface,
                          foregroundColor: isFilterExpanded.value
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          elevation: 0,
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      if (_hasActiveFilters(historyStateAsync.value))
                        TextButton(
                          onPressed: () {
                            viewModel.clearAllFilters();
                            searchController.clear();
                          },
                          child: const Text('Limpar filtros'),
                        ),
                    ],
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    alignment: Alignment.topCenter,
                    child: isFilterExpanded.value
                        ? const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: HistoryFilterPanel(),
                          )
                        : const SizedBox.shrink(),
                  ),

                  if (historyStateAsync.value != null)
                    _buildActiveFiltersList(
                      context,
                      historyStateAsync.value!,
                      viewModel,
                      colorScheme,
                    ),

                  const SizedBox(height: 16),

                  if (historyStateAsync.value?.isRefreshingFilters ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ]),
              ),
            ),

            historyStateAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text('Erro ao carregar: ${err.toString()}'),
                      TextButton(
                        onPressed: () => viewModel.refresh(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (state) {
                if (state.transactions.isEmpty && !state.isRefreshingFilters) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma transação encontrada',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.transactions.length) {
                          if (state.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (state.loadMoreError != null) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: TextButton(
                                  onPressed: viewModel.loadNextPage,
                                  child: Text(
                                    'Erro. Tentar carregar mais: ${state.loadMoreError}',
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox(height: 80);
                        }

                        final transaction = state.transactions[index];
                        return Opacity(
                          opacity: state.isRefreshingFilters ? 0.5 : 1.0,
                          child: TransactionListItem(transaction: transaction),
                        );
                      },
                      childCount:
                          state.transactions.length + (state.hasMore ? 1 : 0),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters(dynamic state) {
    if (state == null) return false;
    return state.typeFilter != null ||
        state.startDate != null ||
        state.selectedGroupIds.isNotEmpty ||
        state.selectedCategories.isNotEmpty;
  }

  Widget _buildActiveFiltersList(
    BuildContext context,
    dynamic state,
    dynamic viewModel,
    ColorScheme colorScheme,
  ) {
    final chips = <Widget>[];

    if (state.typeFilter != null) {
      chips.add(
        _buildActiveChip(
          label: state.typeFilter == TransactionType.income
              ? 'Receitas'
              : 'Despesas',
          onDeleted: () => viewModel.setTypeFilter(null),
          colorScheme: colorScheme,
        ),
      );
    }

    if (state.startDate != null && state.endDate != null) {
      final dateStr =
          '${DateFormat('dd/MM').format(state.startDate!)} - ${DateFormat('dd/MM').format(state.endDate!)}';
      chips.add(
        _buildActiveChip(
          label: dateStr,
          onDeleted: () => viewModel.clearDateFilter(),
          colorScheme: colorScheme,
        ),
      );
    }

    for (final groupId in state.selectedGroupIds) {
      final group = state.availableGroups.firstWhere(
        (g) => g.id == groupId,
        orElse: () => GroupModel(
          id: 0,
          name: 'Grupo $groupId',
          createdAt: DateTime.now(),
        ),
      );

      chips.add(
        _buildActiveChip(
          label: group.name,
          onDeleted: () {
            final newList = List<int>.from(state.selectedGroupIds)
              ..remove(groupId);
            viewModel.updateFilters(groupIds: newList);
          },
          colorScheme: colorScheme,
        ),
      );
    }

    for (final category in state.selectedCategories) {
      chips.add(
        _buildActiveChip(
          label: category,
          onDeleted: () {
            final newList = List<String>.from(state.selectedCategories)
              ..remove(category);
            viewModel.updateFilters(categories: newList);
          },
          colorScheme: colorScheme,
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }

  Widget _buildActiveChip({
    required String label,
    required VoidCallback onDeleted,
    required ColorScheme colorScheme,
  }) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
      deleteIconColor: colorScheme.onPrimaryContainer,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}
