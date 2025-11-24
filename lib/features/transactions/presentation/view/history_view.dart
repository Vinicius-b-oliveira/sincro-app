import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

    // Listener de Busca
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
                  const SizedBox(height: 16),
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
                if (state.transactions.isEmpty) {
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
                        return TransactionListItem(transaction: transaction);
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
}
